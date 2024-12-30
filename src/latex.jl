textsc(str) = join(map(s->"\\textsc{$(uppercase(s))}", split_camel_case(str)))

function _latex(text::String)
	text = replace(text, "``"=>"\"")
	text = replace(text, "''"=>"\"")
	text = replace(text, "`"=>"'")
	text = replace(text, r"\\textit{(.*?)}"=>s"_\1_")
	text = replace(text, r"\\textbf{(.*?)}"=>s"**\1**")
	text = replace(text, r"\\texttt{(.*?)}"=>s"`\1`")
	text = replace(text, r"\\label{(.*?)}"=>"")
	text = wrap_latex_environments(text)
	text = remove_latex_comments(text)
	smallcaps_regex = r"\\smallcaps\{(.*?)\}"
	text = replace(text, smallcaps_regex=>m->begin
		sc = match(smallcaps_regex, m).captures[1]
		return string(raw"$", textsc(sc), raw"$")
	end)
	text = replace(text, "\\minimize_"=>"\\minimize_\\limits")
	text = replace(text, "\\maximize_"=>"\\maximize_\\limits")
	text = replace(text, "\\argmin_"=>"\\argmin_\\limits")
	text = replace(text, "\\argmax_"=>"\\argmax_\\limits")
	text = replace(text, "\\mathbbm"=>"\\mathbb")
	text = replace(text, "\\vec{\\mu}"=>"𝛍")
	text = replace(text, "\\vec{\\theta}"=>"𝛉")
	text = replace(text, "\\"=>"\\\\")
	text = replace(text, "\$"=>"\\\$")
	text = replace_cite_commands(text)
	text = replace_cref_commands(text)
	text = replace_Cref_commands(text)
	return text
end


macro latex_str(latex)
	if !(latex isa String || latex.args[1] == Symbol("@raw_str"))
		throw(ArgumentError("@latex_str macro needs to take in either a string or a raw string"))
	end
	latex = eval(latex)
	latex = _latex(string(latex))
	interpolated_string_expr = Meta.parse("\"\"\"$latex\"\"\"")
	return esc(quote
		let
			m = Markdown.parse($interpolated_string_expr)
			m = apply_ref!(m)
			append_ref_update!(m, PlutoPapers.FIGURE_REFS)
		end
	end)
end


function alg(raw_latex; label="", num=1, caption="Caption", type="Algorithm")
	if !isempty(label)
		p = "<p class='algorithm-caption' id='$label'>"
	else
		p = "<p class='algorithm-caption'>"
	end
	PlutoUI.@htl("""
	<div>
	$(HTML(p))
	<b>$type $num</b> $caption
	</p>
	<span class='algorithm'>
	$(alg2md(raw_latex))
	</span>
	</div>
	""")
end


function alg2md(latex_str::String)
    # Split the input into lines
    lines = split(latex_str, '\n')
    
    # Initialize variables
    indent_level = 0
    output_lines = String[]
    
    # Define regex patterns for commands
    function_regex = r"\\Function\{([\w-]+)\}\{(.*)\}"
    for_regex = r"\\For\s*\{(.*)\}"
    state_regex = r"\\State\s+(.*)"
    return_regex = r"\\State\s+\\Return\s+(.*)"
    end_regex = r"\\End(Function|For)"
    textproc_regex = r"\\textproc\{(.*?)\}"

    for line in lines
        # Trim whitespace
        trimmed = strip(line)
		# $ where $ => \text{ where }
		trimmed = replace(trimmed, r"\$(\s[\w\s]+\s)"=>s"\\text{\1}")
		trimmed = replace(trimmed, "\$"=>"")
		# \algorithmiccomment{elite set} => $\qquad\rhd\text{elite set}$
		trimmed = replace(trimmed, r"\\algorithmiccomment\{(.*)\}"=>s"\\qquad\\rhd\\text{\1}")
		trimmed = replace(trimmed, textproc_regex=> m->begin
			procname = match(textproc_regex, m).captures[1]
			return textsc(procname)
		end)
        
        # Skip begin and end of algorithm and algorithmic environments
        if startswith(trimmed, "\\begin{algorithm}") || startswith(trimmed, "\\begin{algorithmic}") ||
           startswith(trimmed, "\\end{algorithmic}") || startswith(trimmed, "\\end{algorithm}") ||
           startswith(trimmed, "\\caption{") || isempty(trimmed)
            continue
        end
        
        # Match \Function
        m = match(function_regex, trimmed)
		
		if !isnothing(m)
            func_name = m.captures[1]
            params = m.captures[2]
            # Construct the Markdown line
            md_line = "\\textbf{function } $(textsc(func_name))($params)\$\\"
            # Indentation string
            indent_str = repeat("\\qquad ", indent_level)
            # Combine blockquote and line
            push!(output_lines, "  \$" * indent_str * md_line)
            # Increase indent
            indent_level += 1
            continue
        end
        
        # Match \For
        m = match(for_regex, trimmed)
		if !isnothing(m)
            condition = m.captures[1]
            # Construct the Markdown line
            md_line = "\\textbf{for } {$condition}\$\\"
            # Indentation string
            indent_str = repeat("\\qquad ", indent_level)
            # Combine blockquote and line
            push!(output_lines, " \$" * indent_str * md_line)
            # Increase indent
            indent_level += 1
            continue
        end

		# Match \Return
        m = match(return_regex, trimmed)
		if !isnothing(m)
            return_content = m.captures[1]
            # Wrap in $...$ with proper indentation
            md_line = "\\textbf{return } $return_content\$"
            # Indentation string
            indent_str = repeat("\\qquad ", indent_level)
            # Combine blockquote and line
            push!(output_lines, " \$" * indent_str * md_line)
            continue
        end

        # Match \State
        m = match(state_regex, trimmed)
		if !isnothing(m)
            state_content = m.captures[1]
            # Wrap in $...$ with proper indentation
            md_line = state_content * "\$\\"
            # Indentation string
            indent_str = repeat("\\qquad ", indent_level)
            # Combine blockquote and line
            push!(output_lines, " \$" * indent_str * md_line)
			continue
		end

        
        # Match \EndFunction or \EndFor
        m = match(end_regex, trimmed)
		if !isnothing(m)
            # Decrease indentation
            indent_level = max(indent_level - 1, 0)
            continue
        end
        
        # For other lines, skip or handle accordingly
        # For this specific use-case, we skip other lines
        continue
    end

    # Join output lines with newlines
    markdown_content = join(output_lines, "\n")
	# println(markdown_content)
    return Markdown.parse(markdown_content)
end

function replace_cite_commands(text::String, cmds=["cite", "ref", "cref", "Cref"])
	# for cmd in cmds
	# 	pattern = Regex("\\\\$(cmd)\\{([^}]+)\\}") # NOTE: double \
	#     text = replace(text, pattern => m -> begin
	# 		names_str = match(pattern, m).captures[1]
	#         names = split(names_str, r"\s*,\s*")
	#         formatted_names = join([":" * name for name in names], ", ")
	#         return "\$(cite($formatted_names))"
	#     end)
	# end
	# return text
	pattern = r"\\\\cite\{([^}]+)\}" # NOTE: double \
	return replace(text, pattern => m -> begin
		names_str = match(pattern, m).captures[1]
		names = split(names_str, r"\s*,\s*")
		formatted_names = join([":" * name for name in names], ", ")
		return "\$(cite($formatted_names))"
	end)
end


function replace_cref_commands(text::String)
	pattern = r"\\\\cref\{([^}]+)\}" # NOTE: double \
	return replace(text, pattern => m -> begin
		names_str = match(pattern, m).captures[1]
		names = split(names_str, r"\s*,\s*")
		formatted_names = join([":" * replace(name, ":"=>"_") for name in names], ", ")
		return "\$(cref($formatted_names))"
	end)
end


function replace_Cref_commands(text::String)
	pattern = r"\\\\Cref\{([^}]+)\}" # NOTE: double \
	return replace(text, pattern => m -> begin
		names_str = match(pattern, m).captures[1]
		names = split(names_str, r"\s*,\s*")
		formatted_names = join([":" * replace(name, ":"=>"_") for name in names], ", ")
		return "\$(Cref($formatted_names))"
	end)
end


function wrap_latex_environments(text::String)
    pattern = r"(?s)\\begin\{(align\*?|gather\*?|equation\*?)\}(.*?)\\end\{\1\}"
    replacement = s"""

	$$\\begin{\1}\2\\end{\1}$$

	"""
    return replace(text, pattern => replacement)
end


"""
Removes LaTeX comments from the input string, ignoring escaped percent signs.

# Arguments
- `latex_str::String`: The input string containing LaTeX code.

# Returns
- `String`: The LaTeX string with comments removed, preserving escaped '%'.
"""
function remove_latex_comments(latex_str::String)
    # Regex explanation:
    # (?<!\\)  - Negative lookbehind to ensure '%' is not preceded by a backslash
    # %.*$     - '%' followed by any characters until the end of the line
    pattern = r"(?<!\\)%.*"
    
    # Use replace with the pattern and multiline flag
    cleaned_str = replace(latex_str, pattern => "")
    
    return cleaned_str
end


"""
Split the string at positions before each uppercase letter.
"""
split_camel_case(str) = split(str, r"(?=[A-Z])")


# TODO
function cite(args...)
	return "[?]"
end


# TODO
function cref(args...)
	# TODO: Multiple arg refs
	label = replace(string(args[1]), "_"=>"-")
	return "figure <cref#$label>"
end


# TODO
function Cref(args...)
	return "Section ?"
end
