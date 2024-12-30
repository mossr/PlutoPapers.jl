toc = TableOfContents

function style(css)
	return HTML("""
	<style>
		$css
	</style>
	""")
end

function hide_cell(cellid)
	cellid = string(cellid)
	return """
		<script>
		const cell = document.getElementById("$cellid");
		const hide = cell.querySelector(".foldcode"); 
		if (hide && !cell.classList.contains("code_folded")) {
			hide.click();
		}
		</script>
	"""
end

macro hide_all_cells()
    esc(quote
        HTML(join(map(hide_cell, collect(keys(PlutoRunner.cell_results)))))
    end)
end

function show_cell(cellid)
	cellid = string(cellid)
	return """
		<script>
		const cell = document.getElementById("$cellid");
		const show = cell.querySelector(".foldcode"); 
		if (show && !cell.classList.contains("show_input")) {
			show.click();
		}
		</script>
	"""
end

macro show_all_cells()
    esc(quote
        HTML(join(map(show_cell, collect(keys(PlutoRunner.cell_results)))))
    end)
end

function update_numbering()
	"""
	<script>
	var section = 0; // hidden "Preview" <h2>?
	var subsection = 0;
	var subsubsection = 0;
	var headers = document.querySelectorAll('.title, .section, .subsection, .subsubsection');
	for (var i=0; i < headers.length; i++) {
	    var header = headers[i];
		if (header.classList.contains('title')) {
			section = 0; // Reset section counter based on new Titles
			continue;
		}
		var text = header.innerText;
		var original = header.getAttribute("text-original");
		if (original === null) {
			// Save original header text
			header.setAttribute("text-original", text);
		} else {
			// Replace with original text before adding section number
			text = header.getAttribute("text-original");
		}
		var numbering = "";
		switch (header.tagName) {
			case 'H2':
				section += 1;
				numbering = section; // + "."; // Removes trailing period
				subsection = 0;
				break;
			case 'H3':
				subsection += 1;
				numbering = section + "." + subsection;
				break;
			case 'H4':
				subsubsection += 1;
				numbering = section + "." + subsection + "." + subsubsection;
				break;
		}
		header.innerText = numbering + " " + text; // quad space: https://www.compart.com/en/unicode/U+2001
	};
	</script>
	"""
end

function get_aspect_ratio()
	x_range = xlims()[2] - xlims()[1]
	y_range = ylims()[2] - ylims()[1]
	return x_range/y_range
end

function set_aspect_ratio!()
	ratio = get_aspect_ratio()
	plot!(ratio=ratio)
end

function plot_default(; dark_mode=false, kwargs...)
    default(
		fontfamily="Computer Modern",
		framestyle=:box,
		titlefontsize=10,
		label=false,
		grid=false,
		xguidefontfamily="Computer Modern", # Better LaTeX strings
		yguidefontfamily="Computer Modern", # Better LaTeX strings
		bg="transparent",
		background_color_inside=dark_mode ? "#1A1A1A" : "white",
		fg=dark_mode ? "white" : "black",
        kwargs...
	)
end