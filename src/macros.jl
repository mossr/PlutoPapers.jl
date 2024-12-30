macro abstract(body)
	return quote
		Markdown.MD(HTML("""
			$(update_numbering())
			<div class='abstract'>
			<h2 id='abstract' class='abstract'>Abstract</h2>
			<p>"""),
			$(body isa String ? HTML(body) : body),
			html"</p></div>")
	end
end

macro create(macro_name::Symbol, tag::Symbol)
    tag_str = string(tag)
    class = string(macro_name)
    macro_name_esc = esc(macro_name)
    
    return quote
        # Define a helper function for generating HTML
        function $(Symbol("generate_html_", macro_name))($:tag, title, label)
            return HTML(string(
                update_numbering(),
                # hide_cell(string(PlutoRunner.currently_running_cell_id[])),
                "<", tag, " class='", $class, "' id='", label, "'>", title, "</", tag, ">"
            ))
        end

        # Define the single-argument macro
        macro $(macro_name_esc)(title)
            label = lowercase(replace(title, " " => "-"))
            return $(Symbol("generate_html_", macro_name))($(tag_str), title, label)
        end

        # Define the two-argument macro
        macro $(macro_name_esc)(title, label)
            return $(Symbol("generate_html_", macro_name))($(tag_str), title, label)
        end
    end
end

@create section h2
@create subsection h3
@create subsubsection h4

macro paragraph(name, body)
	return quote
		if $body isa String
			HTML(string(
				# $(hide_cell(string(PlutoRunner.currently_running_cell_id[]))),
				"<p class='paragraph'><b>", $name, ".</b> ", $body)) # quad space " "
		  else
			  Markdown.MD(Markdown.parse(string("**", $name, ".** ", $body))) # quad space " "
		end
	end
end

macro references(body)
	return quote
		Markdown.MD(HTML("""
			$(update_numbering())
			<div class='references'>
			<h2 id='references' class='references'>References</h2>
			<p>"""),
			$(body isa String ? HTML(body) : body),
			html"</p></div>")
	end
end

@create star h2