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

# ╔═╡ b4b5cbff-b290-48dc-98dc-8f4522962501
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.develop(path="..")
	using Revise
	using PlutoPapers
	using Distributions
	set_default_lipsum_markdown()
end;

# ╔═╡ b6b100f6-bcfc-44ea-9f9a-77ac9893b9d7
begin
	paper = PlutoPaper(
		documentclass=NeurIPS(),
		include_affiliations=true,
		include_emails=true,
		title="BetaZero: Belief-State Planning for Long-Horizon <br> POMDPs using Learned Approximations",
		authors=[
			Author(
				name="Robert J. Moss",
				affiliation="Computer Science Department",
				email="mossr@stanford.edu"),
			Author(
				name="Anthony Corso",
				affiliation="Aeronautics and Astronautics Department",
				email="acorso@stanford.edu"),
			Author(
				name="Jef Caers",
				affiliation="Earth and Planetary Sciences Department, Stanford University",
				email="jcaers@stanford.edu"),
			Author(
				name="Mykel J. Kochenderfer",
				affiliation="Aeronautics and Astronautics Department",
				email="mykel@stanford.edu"),
		],
	)

	Markdown.MD(
		applyclass(paper.documentclass),
		md" $\def\textsc#1{\dosc#1\csod} \def\dosc#1#2\csod{{\rm #1{\small #2}}}$",
		FootnotesRawNumbered(),
		toc(depth=4),
	)
end

# ╔═╡ 50cae4c4-7a13-4dfc-b247-47a33f830962
title(paper; break_at=3)

# ╔═╡ bf9f232a-51df-4c34-a508-904cae105f58
@abstract Markdown.MD(md"""
Real-world planning problems—including autonomous driving and sustainable energy applications like carbon storage and resource exploration—have recently been modeled as partially observable Markov decision processes (POMDPs) and solved using approximate methods.
To solve high-dimensional POMDPs in practice, state-of-the-art methods use online planning with problem-specific heuristics to reduce planning horizons and make the problems tractable.
Algorithms that learn approximations to replace heuristics have recently found success in large-scale problems in the fully observable domain.
The key insight is the combination of online Monte Carlo tree search with offline neural network approximations of the optimal policy and value function.
In this work, we bring this insight to partially observed domains and propose _BetaZero_, a belief-state planning algorithm for POMDPs.
BetaZero learns offline approximations based on accurate belief models to enable online decision making in long-horizon problems.
We address several challenges inherent in large-scale partially observable domains;
namely challenges of
transitioning in stochastic environments,
prioritizing action branching with limited search budget,
and representing beliefs as input to the network.
We apply BetaZero to various well-established benchmark POMDPs found in the literature.
As a real-world case study, we test BetaZero on the high-dimensional geological problem of critical mineral exploration.
Experiments show that BetaZero
outperforms state-of-the-art POMDP solvers on a variety of tasks.[^github]""",
sidenote(md"[^github]: [https://github.com/sisl/BetaZero.jl](https://github.com/sisl/BetaZero.jl)"; v_offset=400))

# ╔═╡ c0a0f3c9-3493-4bd7-9133-9d873d720a06
@section "Introduction"

# ╔═╡ 089a350c-9c2f-448e-9300-fc7f668dbd92
lipsum(1:3)

# ╔═╡ 5d8bc3ad-25c4-4d96-aaf5-4acd4854b372
md" $\sigma =$ $(@bind σ Slider(0.01:0.01:1, show_value=true, default=0.2))"

# ╔═╡ c5a89290-eaf4-43b5-b42d-9d3b8ff6ac85
@section "Related work"

# ╔═╡ 44e06650-708b-4ffa-a3d0-5e4e20de19cc
Markdown.MD(
	md"""
	Lorem ipsum dolor sit amet,[^footnote2] consectetur adipiscing elit. Pellentesque lorem diam, pharetra ut suscipit eget, placerat vel quam. Vestibulum auctor et metus id tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Suspendisse a lacus nec diam gravida laoreet. Mauris lobortis, odio et malesuada facilisis, lacus mi porta nunc, ac dapibus nulla nisl ut leo. Nam sagittis nulla quis dolor sagittis mollis.
	""",
	sidenote(md"[^footnote2]: Here is some extra information to consider as a sidenote. For more details about how to use the `sidenote`, see the documentation."; v_offset=0),
	lipsum(2:3)
)

# ╔═╡ 849abb31-8206-4bb8-a2eb-22aa3192bacc
@section "Background"

# ╔═╡ 8ff63aa1-75b9-4378-8c3e-355bbbb6a9ef
lipsum(1)

# ╔═╡ 66f20a03-a7dc-4992-9940-6c50803842ea
@paragraph "Belief-state MDPs" md"""
In _belief-state_ MDPs, the POMDP is converted to an MDP by treating the
belief as a state [21]. The reward function then becomes a weighted sum of the state-based reward:

 $$R_b(b,a) = \int_{s \in \mathcal{S}} b(s) R(s,a) \mathrm{d}s \approx \sum_{s \in b}b(s)R(s,a)$$

The belief-state MDP has the same state and action spaces as the POMDP and defines the new belief-state transition function $T_b(b' \mid b, a)$ as:

 $$s \sim b(\cdot) \quad s' \sim T(\cdot \mid s, a) \quad o \sim O(\cdot \mid a, s') \quad b' \leftarrow \textsc{UPDATE}(b,a,o)$$"""

# ╔═╡ 304edf96-f21b-46c7-bd24-e52df451e706
lipsum(3)

# ╔═╡ 7acde591-ede9-4081-8a0f-90c6686c0296
@section "Methodology"

# ╔═╡ 3ad942b7-aa0c-4f47-91d0-93202a5ac483
lipsum(1:2)

# ╔═╡ 214a5b2d-5c25-47a3-806f-d4f10d1a3171
md" $\sigma =$ $(@bind σ2 Slider(0:50, show_value=true, default=25))"

# ╔═╡ 5102e1e8-797f-4737-b27c-9eb0002050f2
lipsum(75)

# ╔═╡ c3426732-c4f9-488f-9f01-9d193ca78f77
@subsection "Subsection"

# ╔═╡ d76e40a6-585b-4a11-b6ef-ec61a3e7d5a5
lipsum(1:2)

# ╔═╡ 3e8769ef-e9d0-4f22-9c9d-f7110c5790c9
table(md"""
| Algorithm | Metric | Runtime |
| :-------- | -----: | ------: |
| `BetaZero` | 123 ± 4.56 | 789 s |
| `ConstrainedZero` | 321 ± 6.54 | 987 s |
| `MCTS` | 978 ± 5.46 | 343 s |
"""; caption="Results")

# ╔═╡ e7fab526-6c7a-4562-984b-c7ef90aca3ab
@subsubsection "Subsubsection"

# ╔═╡ 440526b5-3b47-4ecd-86ea-81be9eb2c24a
lipsum(66:67)

# ╔═╡ 9d45db10-4977-4632-8fb7-fdbc83f10287
code(md"""
```julia
using Distributions

function thompson_sampling(𝛂, 𝛃, apply; T=100)
    for t in 1:T
        𝛉 = rand.(Beta.(𝛂, 𝛃))
        x = argmax(𝛉)
        r = apply(x)
        𝛂[x], 𝛃[x] = (𝛂[x] + r, 𝛃[x] + 1 - r)
    end
    return Beta.(𝛂, 𝛃)
end
```"""; caption="The Thompson sampling algorithm.")

# ╔═╡ 7a683f97-8a82-4f7c-ad4f-61abb98785c1
@section "Conclusions"

# ╔═╡ 554c888d-126f-4686-8bde-36f2d08a3a73
lipsum(52:53)

# ╔═╡ 1105ac2e-b0ca-453c-82ae-c1632c9fffe0
@star "Acknowledgments"

# ╔═╡ 4ad1ec62-4ebb-47cd-8b2f-5e503e5a3606
lipsum(1)

# ╔═╡ 4d34e01b-8389-4917-aead-52933b0ddc26
@references md"""
1. R. J. Moss, A. Corso, J. Caers, and M. J. Kochenderfer. Beta Zero: Belief-State Planning for Long Horizon POMDPs using Learned Approximations. _Reinforcement Learning Journal_, 1(1), 2024.


2. R. J. Moss, A. Jamgochian, J. Fischer, A. Corso, and M. J. Kochenderfer. ConstrainedZero: Chance-Constrained POMDP Planning Using Learned Probabilistic Failure Surrogates and Adaptive Safety Constraints. _International Joint Conference on Artificial Intelligence (IJCAI)_, 2024.
"""

# ╔═╡ f1a56e54-c54f-4b72-8f8f-bf022e490ee6
@bind dark_mode DarkModeIndicator()

# ╔═╡ 99b9e616-5535-458e-a27c-50019da6fb8f
begin
	paper # trigger documentclass change

	# Parameters
	N = 1000
	x_min = 0
	x_max = 10π
	x = LinRange(x_min, x_max, N)
	
	amplitude = 1.0
	frequency = 1.0
	
	slope = 0.1
	intercept = 0.0
	
	# Generate data
	y_linear = slope .* x .+ intercept
	y_sine = amplitude .* sin.(frequency .* x)
	y_trend_sine = y_linear .+ y_sine
	noise = randn(N) .* σ
	y_noisy = y_trend_sine .+ noise
	
	# Plotting
	plot(x, y_noisy,
	     title="Linear Sine Wave with Gaussian Noise",
	     xlabel=L"x",
	     ylabel=L"sx + b + a\sin(cx) + \epsilon",
	     label="Noisy Signal (𝜎 = $σ)",
	     linewidth=1,
		 legend=:topleft,
	     color=dark_mode ? :white : :black,
		 ylims=(-2, 5))

	figure(plot!(); caption="Dynamically adjust the 𝜎 noise level")
end

# ╔═╡ 8bb8376d-8c67-403e-b61d-79e9425552ec
figure(plot(collect(1:1000) .+ σ2*randn(1000);
	size=(600,300),
	label="Data",
	xlabel="Inputs",
	ylabel="Outputs",
	margin=2Plots.mm,
	ylims=(-100,1100),
	color=dark_mode ? :white : :black,
))

# ╔═╡ f7fcf277-2013-4078-bf58-6ff3c2f24e2f
plot_default(; dark_mode)

# ╔═╡ 265023f5-172e-452b-943a-5bfd342c8af1
@hide_all_cells

# ╔═╡ Cell order:
# ╟─b6b100f6-bcfc-44ea-9f9a-77ac9893b9d7
# ╟─50cae4c4-7a13-4dfc-b247-47a33f830962
# ╟─bf9f232a-51df-4c34-a508-904cae105f58
# ╟─c0a0f3c9-3493-4bd7-9133-9d873d720a06
# ╟─089a350c-9c2f-448e-9300-fc7f668dbd92
# ╟─99b9e616-5535-458e-a27c-50019da6fb8f
# ╟─5d8bc3ad-25c4-4d96-aaf5-4acd4854b372
# ╟─c5a89290-eaf4-43b5-b42d-9d3b8ff6ac85
# ╟─44e06650-708b-4ffa-a3d0-5e4e20de19cc
# ╟─849abb31-8206-4bb8-a2eb-22aa3192bacc
# ╟─8ff63aa1-75b9-4378-8c3e-355bbbb6a9ef
# ╟─66f20a03-a7dc-4992-9940-6c50803842ea
# ╟─304edf96-f21b-46c7-bd24-e52df451e706
# ╟─7acde591-ede9-4081-8a0f-90c6686c0296
# ╟─3ad942b7-aa0c-4f47-91d0-93202a5ac483
# ╟─8bb8376d-8c67-403e-b61d-79e9425552ec
# ╟─214a5b2d-5c25-47a3-806f-d4f10d1a3171
# ╟─5102e1e8-797f-4737-b27c-9eb0002050f2
# ╟─c3426732-c4f9-488f-9f01-9d193ca78f77
# ╟─d76e40a6-585b-4a11-b6ef-ec61a3e7d5a5
# ╟─3e8769ef-e9d0-4f22-9c9d-f7110c5790c9
# ╟─e7fab526-6c7a-4562-984b-c7ef90aca3ab
# ╟─440526b5-3b47-4ecd-86ea-81be9eb2c24a
# ╟─9d45db10-4977-4632-8fb7-fdbc83f10287
# ╟─7a683f97-8a82-4f7c-ad4f-61abb98785c1
# ╟─554c888d-126f-4686-8bde-36f2d08a3a73
# ╟─1105ac2e-b0ca-453c-82ae-c1632c9fffe0
# ╟─4ad1ec62-4ebb-47cd-8b2f-5e503e5a3606
# ╟─4d34e01b-8389-4917-aead-52933b0ddc26
# ╟─b4b5cbff-b290-48dc-98dc-8f4522962501
# ╟─f1a56e54-c54f-4b72-8f8f-bf022e490ee6
# ╟─f7fcf277-2013-4078-bf58-6ff3c2f24e2f
# ╟─265023f5-172e-452b-943a-5bfd342c8af1
