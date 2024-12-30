function figure(plt; label="", caption="Caption")
	if !isempty(label)
		label = replace(label, ":"=>"-")
		label = replace(label, "_"=>"-")
		div = "<div class='figure-wrapper' id='$label'>"
		addfigref!(label)
	else
		div = "<div class='figure-wrapper'>"
	end
	if caption isa Markdown.MD
		caption = html(caption)
		caption = replace(caption, "<p>"=>"")
		caption = replace(caption, "</p>"=>"")
		caption = HTML(caption)
	end
	@htl("""
	$(HTML(div))
	<p class='figure'>
		$plt
		<br>
		<span class='figure-caption'></span>
		$caption
	</p>
	$(HTML(update_figure_numbering()))
	</div>
	""")
end

function table(tbl; label="", num=1, caption="Caption")
	if !isempty(label)
		label = replace(label, ":"=>"-")
		label = replace(label, "_"=>"-")
		div = "<div id='$label'>"
		addfigref!(label) # TODO: table refs
	else
		div = "<div>"
	end
	if caption isa Markdown.MD
		caption = html(caption)
		caption = replace(caption, "<p>"=>"")
		caption = replace(caption, "</p>"=>"")
		caption = HTML(caption)
	end
	@htl("""
	$(HTML(div))
	<p class='figure'>
		<span class='table-caption'></span>
		Table $num: $caption
	</p>
	$tbl
	</div>
	""")
end

function code(cde; label="", num=1, caption="Caption", type="Code")
	if !isempty(label)
		label = replace(label, ":"=>"-")
		label = replace(label, "_"=>"-")
		div = "<div id='$label'>"
		addfigref!(label) # TODO: table refs
	else
		div = "<div>"
	end
	if caption isa Markdown.MD
		caption = html(caption)
		caption = replace(caption, "<p>"=>"")
		caption = replace(caption, "</p>"=>"")
		caption = HTML(caption)
	end
	@htl("""
	$(HTML(div))
	$cde
	<p class='figure'>
		<span class='table-caption'></span>
		$type $num: $caption
	</p>
	</div>
	""")
end

# function alg(raw_latex; label="", num=1, caption="Caption", type="Algorithm")
# 	if !isempty(label)
# 		p = "<p class='figure-caption' id='$label'>"
# 	else
# 		p = "<p class='figure-caption'>"
# 	end
# 	@htl("""
# 	<div>
# 	<p class='algorithm'>
# 	$(alg2md(raw_latex))
# 	$(HTML(p))$type $num: $caption.
# 	</p>
# 	</div>
# 	""")
# end


function update_figure_numbering()
	"""
	<script>
	var figure_num = 0;
	var figures = document.querySelectorAll('.figure-caption');
	for (var i=0; i < figures.length; i++) {
	    var figure = figures[i];
		if (figure.classList.contains('title')) {
			figure_num = 0; // Reset figure counter based on new Titles
			continue;
		}
		var text = figure.innerText;
		var original = figure.getAttribute("text-original");
		if (original === null) {
			// Save original figure text
			figure.setAttribute("text-original", text);
		} else {
			// Replace with original text before adding figure number
			text = figure.getAttribute("text-original");
		}
		figure_num += 1;
		var element_num = figure.getAttribute("figure-num");
		if (element_num === null) {
			// Save element_num figure number
			figure.setAttribute("figure-num", figure_num);
		}
		var numbering = figure_num; // + "."; // Removes trailing period
		figure.innerText = "Figure " + numbering + ". " + text; // quad space: https://www.compart.com/en/unicode/U+2001
	};
	</script>
	"""
end