### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ aa63f860-b844-11ef-24c6-f93130081744
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.develop(path="..")
	using Revise
	using PlutoPapers
	using Distributions
	using LinearAlgebra
	using StanfordAA228V
	using Random
	using StanfordAA228V.Optim
	import StanfordAA228V.Optim: minimizer
end

# ╔═╡ efb401ef-96e9-4841-81a7-5fa79c09ace7
begin
	presentation = PlutoPaper(
		documentclass=Tufte(),
		title="Algorithms for Validation",
		authors=[
			Author(name="Lecture Introduction")
			# Author(name="Mykel Kochenderfer")
			# Author(name="Sydney Katz")
			# Author(name="Anthony Corso")
			# Author(name="Robert Moss")
		]
	)
	
	applyclass(presentation.documentclass)
end

# ╔═╡ cafe892b-0281-4166-8a51-eb0ebfbad403
title(presentation)

# ╔═╡ 2a0ba439-b203-4b17-bcc0-d8e873b1f561
@section "Introduction"

# ╔═╡ ea47f6ce-38ed-496b-ad25-d588389f42ca
latex"""
Before deploying decision-making systems in high-stakes settings, it is important
to ensure that they will operate as intended. We refer to the process of analyzing
the behavior of these systems as _validation_. Validation is a critical component of
the development process for decision-making systems in a variety of domains
including autonomous vehicles, robotics, and healthcare. As these systems and
their operating environments increase in complexity, understanding the full
spectrum of possible behaviors becomes more challenging and requires a rigorous
validation process. This book discusses these challenges and presents a variety of
computational methods for validating autonomous systems. This chapter begins
with a broad overview of validation. We motivate the need for validation from a
historical perspective and outline the societal consequences of validation failures.
We then introduce the validation framework that we will use throughout the
book. We discuss the challenges associated with validation and conclude with an
overview of the remaining chapters in the book.
"""

# ╔═╡ 348fc07f-0bf0-4b13-808e-4d25edfbd99f
@section "Model Building"

# ╔═╡ a9c5ec8d-b414-4b49-a193-cb1d0806c3b2
latex"""
A system can be described by its environment model $T(s' \mid s, a)$, agent model $\pi(a \mid o)$, and observation model $O(o \mid s)$. Building these models requires the following three steps:
1. _Select a model class._ A \textit{model class} is a set of mathematical models defined by a set of parameters.
2. _Select the parameters for the model class._ This process involves selecting the parameters that best represent the system based on available data or expert knowledge.
3. _Validate the model._ Once selected, the model should be validated to ensure that it accurately represents the system.
"""

# ╔═╡ 51e3a9fc-86b0-4c10-9355-5f7f33858065
@section "Probability Distributions"

# ╔═╡ fc81ad8e-4804-4729-9677-7300c4abce4a
Markdown.MD(
	md"The univariate normal distribution.[^gaussian]",
	latex"""
	\begin{equation}
	\mathcal{N}\Big(x \mid \mu, \sigma^2\Big) = \frac{1}{\sqrt{2 \pi \sigma^2}} \exp\left( -\frac{(x - \mu)^2}{2\sigma^2} \right)
	\end{equation}
	""",
	sidenote(md"[^gaussian]: Here is a longer sidenote explaining more things in detail. This could reference [links](https://aa228v.stanford.edu) or other material."; v_offset=0))

# ╔═╡ b681fd29-c583-425b-aacf-eb21da8ae7a9
md" $\mu =$ $(@bind μ Slider(-4.5:0.1:4.5, show_value=true, default=0))"

# ╔═╡ 943d5b0e-ef2c-4161-8739-6d2c58a07cdf
md" $\sigma^2 =$ $(@bind σ² Slider(0.05:0.05:10, show_value=true, default=1))"

# ╔═╡ eff34297-2faa-411d-8112-83c9df87b55f
@section "Parameter Learning"

# ╔═╡ 5281f7d5-6280-411f-b9a6-e30be74e22f1
md" $n_\text{rollouts} =$ $(@bind n Slider(0:1:100, show_value=true))"

# ╔═╡ 72c72491-6be7-42b8-9226-25fd96056d9a
@star "Appendices"

# ╔═╡ c5e79052-ff35-4db1-a892-f8398f095de2
begin
	agent = ProportionalController([-15., -8.])
	env = InvertedPendulum()
	sensor = AdditiveNoiseSensor(MvNormal(zeros(2), [0.05^2 0; 0 0.2^2]))
	inverted_pendulum = System(agent, env, sensor)
	ψ = LTLSpecification(@formula □(s -> abs(s[1]) < π / 4))
end;

# ╔═╡ 6359952d-16d1-4ac9-a1a3-30aab931b0be
struct MaximumLikelihoodParameterEstimation
    likelihood # p(y) = likelihood(x; θ)
    optimizer  # optimization algorithm: θ = optimizer(f)
end

# ╔═╡ a156376d-2fee-4c86-b9b2-dcf6e306d961
function Distributions.fit(alg::MaximumLikelihoodParameterEstimation, data)
    f(θ) = sum(-logpdf(alg.likelihood(x, θ), y) for (x,y) in data)
    return alg.optimizer(f)
end

# ╔═╡ 3e871bce-145c-46f1-ba0d-6e134754a696
@bind dark_mode PlutoPapers.DarkModeIndicator()

# ╔═╡ 8bdc51d3-5cf1-48e8-8ea3-d136c411ef25
plot_trigger = true; plot_default(; dark_mode)

# ╔═╡ 5cd69f76-a99a-4c9f-906f-0b0cbeca8403
begin
	plot_trigger

	pastel_blue = "#6bb3f0"
	gaussian = Normal(μ, sqrt(σ²))

	gaussian_plot = plot(x->pdf(gaussian, x);
		color=pastel_blue,
		# framestyle=:semi,
		lw=4,
		size=(300,300),
		yaxis=[],
		xlims=(-4, 4),
		xtickfontsize=10,
		x_foreground_color_axis=:transparent,
		xlabel="\$x\$", # Hack to add xlabel vertical space
		# titlefontfamily="Computer Modern", # For better math
		bottommargin=-5Plots.mm,
	)
	ylims!(0, ylims()[2]*1.1)

	# vline!([xlims()[2]], lc=:black, lw=2)
	# hline!([ylims()[2]], lc=:black, lw=2)
	
	PlutoPapers.set_aspect_ratio!()

	figure(gaussian_plot; caption="The normal (Gaussian) distribution")
end

# ╔═╡ 161c15ca-0814-48ee-bbfc-e3a53bcf45b8
begin
	plot_trigger

	pastel_magenta = "#FF48CF"
	viridis_r = cgrad(:viridis, rev=true)

	Random.seed!(1)
	τs = [rollout(inverted_pendulum, d=41) for _ in 1:n]
	s = [step.s[1] for τ in τs for step in τ]
	o = [step.o[1] for τ in τs for step in τ]

	# Random.seed!(4)
	# likelihood(x, θ) = Normal(θ[1] * x + θ[2], exp(θ[3]))
	# optimizer(f) = minimizer(optimize(f, zeros(3), Optim.GradientDescent()))
	# data = zip(s, o)

	# alg = MaximumLikelihoodParameterEstimation(likelihood, optimizer)
	# θ = fit(alg, data)
	# θ = [θ[1], θ[2], exp(θ[3])]

	figure(begin
		plot(;
			xlims=(-0.25, 0.25),
			ylims=(-0.25, 0.25),
			xticks=[-0.2, 0, 0.2],
			yticks=[-0.2, 0, 0.2],
			ratio=1,
			xtickfontsize=10,
			ytickfontsize=10,
			x_foreground_color_axis=:transparent,
			y_foreground_color_axis=:transparent,
		)
		X = Y = range(-0.25, 0.25, 100)
		local Z
		try
			𝒟 = fit_mle(MvNormal, hcat(s,o)')
			Z = [pdf(𝒟, [x,y]) for y in Y, x in X]
		catch err
			Z = zeros(length(X), length(Y))
		end
		heatmap!(X, Y, Z, color=:viridis, colorbar=false)
		scatter!(s, o;
			color=pastel_magenta,
			alpha=0.2,
			msc=pastel_magenta,
			xlabel="""
			
			\$s\$""",
			ylabel="\$o\$",
		)
	end; caption="Sampling the conditional observation model.")
end

# ╔═╡ 5fa58c08-2d18-4340-89c5-5fc4e85c3f4c
FootnotesRawNumbered()

# ╔═╡ 4b83783e-5239-4dca-a429-d50b9ce43863
toc()

# ╔═╡ Cell order:
# ╟─efb401ef-96e9-4841-81a7-5fa79c09ace7
# ╟─cafe892b-0281-4166-8a51-eb0ebfbad403
# ╟─2a0ba439-b203-4b17-bcc0-d8e873b1f561
# ╟─ea47f6ce-38ed-496b-ad25-d588389f42ca
# ╟─348fc07f-0bf0-4b13-808e-4d25edfbd99f
# ╟─a9c5ec8d-b414-4b49-a193-cb1d0806c3b2
# ╟─51e3a9fc-86b0-4c10-9355-5f7f33858065
# ╟─fc81ad8e-4804-4729-9677-7300c4abce4a
# ╟─5cd69f76-a99a-4c9f-906f-0b0cbeca8403
# ╟─b681fd29-c583-425b-aacf-eb21da8ae7a9
# ╟─943d5b0e-ef2c-4161-8739-6d2c58a07cdf
# ╟─eff34297-2faa-411d-8112-83c9df87b55f
# ╟─161c15ca-0814-48ee-bbfc-e3a53bcf45b8
# ╟─5281f7d5-6280-411f-b9a6-e30be74e22f1
# ╟─72c72491-6be7-42b8-9226-25fd96056d9a
# ╠═aa63f860-b844-11ef-24c6-f93130081744
# ╠═c5e79052-ff35-4db1-a892-f8398f095de2
# ╠═6359952d-16d1-4ac9-a1a3-30aab931b0be
# ╠═a156376d-2fee-4c86-b9b2-dcf6e306d961
# ╠═3e871bce-145c-46f1-ba0d-6e134754a696
# ╠═8bdc51d3-5cf1-48e8-8ea3-d136c411ef25
# ╠═5fa58c08-2d18-4340-89c5-5fc4e85c3f4c
# ╠═4b83783e-5239-4dca-a429-d50b9ce43863
