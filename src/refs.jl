global FIGURE_REFS = []

function addfigref!(label)
    global FIGURE_REFS
    label = replace(label, "_"=>"-")
    label = replace(label, ":"=>"-")
    if !(label in FIGURE_REFS)
        push!(FIGURE_REFS, label)
    end
end

function apply_ref!(m::Markdown.MD)
	content = apply_ref!(m.content)
	return Markdown.MD(content)
end

function apply_ref!(p::Markdown.Paragraph)
	content = apply_ref!(p.content)
	return Markdown.Paragraph(content)
end

function apply_ref!(A::Vector)
	new_A = []
	for item in A
		new_item = apply_ref!(item)
		if new_item isa Vector
			push!(new_A, new_item...)
		else
			push!(new_A, new_item)
		end
	end
	return new_A
end

function apply_ref!(s::AbstractString; ref="cref")
	r_ref = capture_label -> "<$ref#$(capture_label ? "(" : "")[\\w\\d\\-]+$(capture_label ? ")" : "")>"
	matches = eachmatch(Regex("(.*?)($(r_ref(false)))(.*?)(?=<$ref#|\$)"), s)
	if isempty(matches)
		return s
	else
        content = []
		for m in matches
			for capture in m.captures
				label_match = match(Regex(r_ref(true)), capture)
				if isnothing(label_match)
					push!(content, capture)
				else
					label = label_match.captures[1]
					# TODO: Toggle if the user wants links or not.
					push!(content, HTML("<a href='#$(label)' id='$(label)-ref'>?</a>"))
				end
			end
		end
		return content
	end
end

apply_ref!(s::Any) = s

function update_refs(refs::Vector)
	html_update = ""
	for id in refs
		html_update *= """<script>
			const wrapper = document.getElementById("$id");
			const caption = wrapper.querySelector(".figure-caption");
			const figureNum = caption.getAttribute("figure-num");
			const elements = document.querySelectorAll("#$(id)-ref");
			elements.forEach(el => {
			el.innerHTML = figureNum;
			});
		</script>"""
	end
	return HTML(html_update)
end

function append_ref_update!(m::Markdown.MD, refs::Vector)
	if isempty(refs)
		return m
	else
		content = deepcopy(m.content)
		if content[end] isa Markdown.Paragraph
			content[end] = Markdown.Paragraph(vcat(content[end].content, update_refs(refs)))
		else
			push!(content, update_refs(refs))
		end
		return Markdown.MD(content)
	end
end
