@with_kw struct Author
	name = ""
	affiliation = ""
	email = ""
end

const Authors = Vector{Author}

@with_kw struct PlutoPaper
	documentclass::DocumentClass = NeurIPS()
	title::String = "Default Title"
	authors::Authors = [Author()]
	include_affiliations = true
	include_emails = true
end

function title(paper::PlutoPaper; kwargs...)
	authors = paper.authors
	names, affiliations, emails = author_block(authors;
		include_affiliations=paper.include_affiliations,
		include_emails=paper.include_emails,
		kwargs...)

	block = """
	$names
	"""
	if !isempty(affiliations)
		block *= """
		<br>
		$affiliations
		"""
	end
	if !isempty(emails)
		block *= """
		<br>
		$emails
		"""
	end

	HTML("""
	<h1 class='title'>$(paper.title)</h1>
	<p class='authors'>
	$block
	</p>
	""")
end

function author_block(authors::Authors; include_affiliations=true, include_emails=true, spaces=2, break_at=missing)
	n = length(authors)
    single_author = n == 1
	quad = " "^spaces
	affiliations = ""
	emails = ""

	if include_affiliations && any(a->!isempty(a.affiliation), authors)
		locations = unique(map(a->a.affiliation, authors))

        if single_author
            names = "<span class='author-name'>$(authors[1].name)</span>"
            all_affiliations = locations
        else
            sup = map(a->findfirst(locations .== a.affiliation), authors)
            names = join(map(i->"<span class='author-name'>$(authors[i].name)</span><sup>$(sup[i])</sup>", eachindex(authors)), quad)
    		all_affiliations = map(i->"<sup>$i</sup>$(locations[i])", eachindex(locations))
        end

		if !ismissing(break_at)
			all_affiliations[break_at] = string("<br>", all_affiliations[break_at])
		end
		affiliations = join(all_affiliations, ", ")
	else
		names = join(map(i->"<span class='author-name'>$(authors[i].name)</span>", eachindex(authors)), quad)
	end

	if include_emails && any(a->!isempty(a.email), authors)
		domains = map(a->a.email[findfirst("@", a.email).start:end], authors)

		if length(unique(domains)) == 1 && length(domains) > 1
			emails = string("{", join(map(a->a.email[1:findfirst("@", a.email).start-1], authors), ","), "}$(domains[1])")
		else
			emails = join(map(a->a.email, authors), ", ")
		end
		emails = string("<code>", emails, "</code>")
	end

	return names, affiliations, emails
end