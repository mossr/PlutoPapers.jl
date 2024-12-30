abstract type DocumentClass end

@with_kw struct NeurIPS <: DocumentClass
	font_family_css = """TimesNewRoman, "Times New Roman", Times, Baskerville, Georgia, serif"""
	font_family_plots = "Times Roman"
	title_style = """
		text-align: center;
		font-size: 20pt !important;
		border-top: 4px solid var(--cursor-color);
		border-bottom: 2px solid var(--cursor-color);
		padding-top: 20px;
		padding-bottom: 20px;
		margin-bottom: 40px;
	"""
	section_style = """
		font-weight: 700;
	"""
	author_style = """
		font-weight: 700;
	"""
end

@with_kw struct Tufte <: DocumentClass
	font_family_css = """Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif"""
	font_family_plots = "Palatino Roman"
	title_style = """
		text-align: center;
		font-size: 20pt !important;
		border-bottom: unset;
		/* padding-top: 0; */
		/* margin-top: 0; */
		border-top: unset;
		border-bottom: unset;
		padding-bottom: 20px;
		margin-bottom: 40px;
		font-weight: unset;
		font-style: italic;
	"""
	section_style = """
		font-weight: unset;
		font-style: italic;
	"""
	author_style = """
		font-weight: unset;
	"""
end

function applyclass(class::DocumentClass=NeurIPS())
	default(fontfamily=class.font_family_plots)
	setstyle(class)
end

function setstyle(class::DocumentClass)
	family = class.font_family_css
	title_style = class.title_style
	section_style = class.section_style
	author_style = class.author_style

	style("""
		.title {
			font-family: $family !important;
			/* font-variant: small-caps; /* TODO: Add option */
			color: var(--cursor-color);
			$title_style
		}
		
		.authors {
			font-family: $family !important;
			font-size: 12pt;
			text-align: justify;
			line-height: 1.2em !important;
			word-spacing: unset;
			hyphens: auto;
			color: var(--cursor-color);
			line-height: 0;
			word-spacing: unset;
			padding-bottom: 20px;
			font-size: 16px;
			text-align: center;
		}

		.author-name {
			$author_style
		}

		.authors code {
			font-size: 10pt;
		}
	
		/* "Abstract" header */
		#abstract {
			$section_style
		}
		
		/* Abstract body */
		.abstract {
			font-family: $family !important;
			font-size: 14pt !important;
			border: unset !important;
			/* margin-top: 2ex !important;*/
			margin-bottom: 1.5ex !important;
			color: var(--cursor-color);
			text-align: center;
			margin-left: 10%;
			margin-right: 10%;
		}

		.star {
			font-family: $family !important;
			font-size: 14pt !important;
			border: unset !important;
			/*margin-top: 2ex !important;*/
			margin-bottom: 1.5ex !important;
			color: var(--cursor-color);
			$section_style
		}

		/* "References" header */
		#references {
			$section_style
		}

		/* References body */
		.references {
			font-family: $family !important;
			font-size: 14pt !important;
			border: unset !important;
			/*margin-top: 2ex !important;*/
			margin-bottom: 1.5ex !important;
			color: var(--cursor-color);
		}
		
		.section {
			font-family: $family !important;
			font-size: 14pt !important;
			border: unset !important;
			/*margin-top: 2ex !important;*/
			margin-bottom: 1.5ex !important;
			color: var(--cursor-color);
			$section_style
		}
		
		.subsection {
			font-family: $family !important;
			font-size: 12pt !important;
			color: var(--cursor-color);
			$section_style
		}
		
		.subsubsection {
			font-family: $family !important;
			font-size: 12pt !important;
			color: var(--cursor-color);
			$section_style
		}

		.figure-wrapper {
			display: flex;
			justify-content: center;
		}
		
		.figure {
			text-align: center;
			margin-top: 20px !important;
			font-family: $family !important;
			font-size: 12pt;
			line-height: 1.2em !important;
			word-spacing: unset;
			hyphens: auto;
			color: var(--cursor-color);
			padding-bottom: 2pt;
		}

        .algorithm-caption {
			font-family: $family !important;
			font-size: 14pt;
			line-height: 1.2em !important;
			word-spacing: unset;
			hyphens: auto;
			color: var(--cursor-color);
            border-top: 2px solid var(--cursor-color);
            padding-top: 1px;
            border-bottom: 1px solid var(--cursor-color);
            padding-bottom: 1px;
            margin-bottom: 4px;
        }

        .algorithm p {
            border-bottom: 1px solid var(--cursor-color);
            padding-bottom: 6px;
        }

		pluto-notebook table {
			font-family: $family !important;
		}
		
		pluto-notebook table td {
			font-family: $family !important;
		}
		
		pluto-notebook .markdown p {
			font-family: $family !important;
			font-size: 12pt;
			text-align: justify;
			line-height: 1.2em !important;
			word-spacing: unset;
			hyphens: auto;
			color: var(--cursor-color);
		}

		pluto-notebook .example p {
			font-family: $family !important;
			font-size: 12pt;
			text-align: justify;
			line-height: 1.2em !important;
			word-spacing: unset;
			hyphens: auto;
			color: var(--cursor-color);
		}
		
		pluto-notebook .markdown li {
			font-family: $family !important;
			font-size: 12pt;
			color: var(--cursor-color);
		}
		
		p:last-child {
			margin-block-end: unset !important;
		}
		
		blockquote {
			font-family: $family !important;
			color: var(--cursor-color);
		}
		
		/*
		pre {
			font-family: $family !important;
			color: var(--cursor-color);
		}
		*/
		
		pluto-output div.footnote p.footnote-title~* {
			border-left: unset !important;
		}
		
		pluto-notebook .footnote {
			font-family: $family !important;
			text-align: justify;
			color: var(--cursor-color);
		}
		
		pluto-notebook .footnote p {
			font-family: $family !important;
			display: inline !important;
			color: var(--cursor-color);
		}
		
		.raw-html-wrapper {
			display: block !important; // hack for scrollbar in author block
		}

		input[type="range"] {
			width: 50%;
			accent-color: var(--cursor-color);
		}

        input[type="checkbox"] {
			accent-color: var(--cursor-color);
		}

		p:has(input) {
			text-align: center !important;
		}

		.raw-html-wrapper:has(input) {
			text-align: center !important;
		}

		pluto-notebook output {
			font-family: $family !important;
		}
	""")
end

