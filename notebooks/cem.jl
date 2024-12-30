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

# ╔═╡ 131f7542-62ca-4581-b745-9262e585bf47
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.develop(path="..")
	using Revise
	using PlutoPapers
	using Distributions
	using Interpolations
	using GaussianMixtures
	set_default_lipsum_markdown()
	md"> _Package management_"
end

# ╔═╡ 9fa5f299-1420-42db-8a02-4f50f79095c2
begin
	paper = PlutoPaper(
		documentclass=NeurIPS(),
		include_affiliations=true,
		include_emails=true,
		title="Cross-Entropy Method Variants for Optimization",
		authors=[
			Author(
				name="Robert J. Moss",
				affiliation="Stanford University, Stanford, CA",
				email="mossr@cs.stanford.edu"),
		],
	)

	Markdown.MD(
		applyclass(paper.documentclass),
		md"""
		 $\newcommand{\E}{\mathbb{E}}$
		 $\newcommand{\R}{\mathbb{R}}$
		 $\newcommand{\minimize}{\operatorname{minimize}}$
		 $\newcommand{\maximize}{\operatorname{maximize}}$
		 $\newcommand{\supremum}{\operatorname{supremum}}$
		 $\newcommand{\argmin}{\operatorname{argmin}}$
		 $\newcommand{\argmax}{\operatorname{argmax}}$
		 $\newcommand{\mat}[1]{\mathbf{#1}}$
		 $\renewcommand{\vec}[1]{\mathbf{#1}}$
		 $\def\textsc#1{\dosc#1\csod} \def\dosc#1#2\csod{{\rm #1{\small #2}}}$
		 $\newcommand{\e}{\mathbf{e}}$
		 $\newcommand{\w}{\mathbf{w}}$
		 $\DeclareMathOperator{\Normal}{\mathcal{N}}$
		 $\newcommand{\m}{\mathbf{m}}$
		 $\newcommand{\M}{\mathbf{M}}$
		 $\newcommand{\bfE}{\mathbf{E}}$
		 $\newcommand{\surrogate}{\hat{S}} % Surrogate model (\mathcal{S})$
		 $\DeclareMathOperator{\Geo}{Geo}$
		 $\DeclarePairedDelimiter{\round}\lfloor\rceil$
		 $\newcommand{\Sierra}{\mathbf{M}_\mathcal{S}}$
		 $\DeclarePairedDelimiter{\norm}{\lVert}{\rVert}$
		""",
		FootnotesRawNumbered(),
		toc(depth=4),
	)
end

# ╔═╡ 2ab1b89c-d1cd-4967-89f3-5767da8acb5d
title(paper)

# ╔═╡ fb1bcfb6-fe57-4134-8bbd-6c9bb16e29d4
@abstract Markdown.MD(md"""
The cross-entropy (CE) method is a popular stochastic method for optimization due to its simplicity and effectiveness.
Designed for rare-event simulations where the probability of a target event occurring is relatively small,
the CE-method relies on enough objective function calls to accurately estimate the optimal parameters of the underlying distribution. 
Certain objective functions may be computationally expensive to evaluate, and the CE-method could potentially get stuck in local minima.
This is compounded with the need to have an initial covariance wide enough to cover the design space of interest.
We introduce novel variants of the CE-method to address these concerns.
To mitigate expensive function calls, during optimization we use every sample to build a surrogate model to approximate the objective function.
The surrogate model augments the belief of the objective function with less expensive evaluations.
We use a Gaussian process for our surrogate model to incorporate uncertainty in the predictions which is especially helpful when dealing with sparse data.
To address local minima convergence, we use Gaussian mixture models to encourage exploration of the design space.
We experiment with evaluation scheduling techniques to reallocate true objective function calls earlier in the optimization when the covariance is the largest.
To test our approach, we created a parameterized test objective function with many local minima and a single global minimum. Our test function can be adjusted to control the spread and distinction of the minima.
Experiments were run to stress the cross-entropy method variants and results indicate that the surrogate model-based approach reduces local minima convergence using the same number of function evaluations.[^github]""",
sidenote(md"[^github]: [CrossEntropyVariants.jl](https://github.com/mossr/CrossEntropyVariants.jl)"; v_offset=440))

# ╔═╡ 735b5dad-50a4-40b0-a10f-1d8aae7a6c03
@section "Introduction"

# ╔═╡ 2fade324-1bdd-4398-a484-e6b30a7f4074
@section "Related work"

# ╔═╡ b6f26239-b73d-495a-a8d7-12a04253d064
@section "Background"

# ╔═╡ d78afeaa-415a-4075-adbe-9f810b09eb0a
md"""
This section provides necessary background on techniques used in this work. We provide introductions to cross-entropy and the cross-entropy method, surrogate modeling using Gaussian processes, and multivariate Gaussian mixture models.
"""

# ╔═╡ fde41ba9-a538-440c-ac87-1ae36e266a48
@subsection "Cross-Entropy"

# ╔═╡ 000e9367-d888-49d3-8b5a-9b520e58c549
@subsection "Cross-Entropy Method"

# ╔═╡ 5ba87ec2-3dd0-48fe-909f-a404ae79b1dd


# ╔═╡ 8abb278a-42fb-4536-80a4-33de4623f403
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{CrossEntropyMethod}{$S, g, m, m_\text{elite}, k_\text{max}$}
    \For {$k \in [1,\ldots,k_\text{max}]$}
        \State $\mat{X} \sim g(\;\cdot \mid \vec{\theta}_k)$ where $\mat{X} \in \R^m$
        \State $\mat{Y} \leftarrow S(\vec{x})$ for $\vec{x} \in \mat{X}$
        \State $\e \leftarrow$ store top $m_\text{elite}$ from $\mat{Y}$
        \State $\vec{\theta}_{k^\prime} \leftarrow \textproc{Fit}(g(\;\cdot \mid \vec{\theta}_k), \e)$
    \EndFor
    \State \Return $g(\;\cdot \mid \vec{\theta}_{k_\text{max}})$
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:cem} Cross-entropy method.}
\end{algorithm}"""; caption="Cross-entropy method.")

# ╔═╡ 96a75973-f078-4c90-bb3b-11eeb9579a37


# ╔═╡ 0c975dcc-2f52-4999-b72e-184e9c42d3ce
@subsection "Mixture Models"

# ╔═╡ 7a61aa58-6f66-4869-9310-5d353101b4f2


# ╔═╡ 37af29bb-85bc-4581-bdc8-0d1274ab2501
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{ExpectationMaximization}{$H, E, 𝛉$}
    \For{\textbf{E-step}}
        \State $\text{Compute } Q(h) = P(H=h \mid E=e, 𝛉) \text{ for each } h$ % (use any probabilistic inference algorithm)
        \State $\text{Create weighted points: } (h,e) \text{ with weight } Q(h)$
    \EndFor
    \For{\textbf{M-step}}
        \State $\text{Compute } \boldsymbol{\hat{𝛉}}_{\text{MLE}}$
    \EndFor
    \State \text{Repeat until convergence.}
    \State \Return $\boldsymbol{\hat{𝛉}}_{\text{MLE}}$
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:em} Expectation-maximization.}
\end{algorithm}"""; num=2, caption="Expectation-maximization.")

# ╔═╡ 738eeac7-a92d-406d-bb08-5a17b6c801e5


# ╔═╡ edb7636c-09b9-42ed-8f8e-c7f14c4d95e4
@subsection "Surrogate Models"

# ╔═╡ 3d4f2127-d373-4286-a87f-22150893b561
@section "Algorithms"

# ╔═╡ e275b803-2d90-41ac-a7ec-0789e42b69a2
@subsection "Cross-Entropy Surrogate Method"

# ╔═╡ 740a134f-3835-4a59-b261-8036f9274dda


# ╔═╡ ecfc4a73-2530-4bd0-9f24-005c8bf154bb
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{CE-Surrogate}{$S$, $\M$, $m$, $m_\text{elite}$, $k_\text{max}$}
    \For {$k \in [1,\ldots,k_\text{max}]$}
        \State $m, m_\text{elite} \leftarrow \textproc{EvaluationSchedule}(k, k_\text{max})$
        \State $\mat{X} \sim \M(\;\cdot \mid \vec{\theta}_k)$ where $\mat{X} \in \R^m$
        \State $\mat{Y} \leftarrow S(\vec{x})$ for $\vec{x} \in \mat{X}$
        \State $\e \leftarrow$ store top $m_\text{elite}$ from $\mat{Y}$
        \State $\bfE \leftarrow \textproc{ModelEliteSet}(\mat{X}, \mat{Y}, \M, \e, m, m_\text{elite})$
        \State $\vec{\theta}_{k^\prime} \leftarrow \textproc{Fit}(\M(\;\cdot \mid \vec{\theta}_k), \bfE)$
    \EndFor
    \State \Return $\M(\;\cdot \mid \vec{\theta}_{k_\text{max}})$
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:ce_surrogate} Cross-entropy surrogate method.}
\end{algorithm}"""; num=3, caption="Cross-entropy surrogate method.")

# ╔═╡ 4590eedc-bb30-47bf-a2f0-44adc7924131


# ╔═╡ e2d30e72-1da3-4d83-8b7b-ae85e23e1c3d


# ╔═╡ 99b6cb8d-b0dc-4517-993a-912640531d19
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{ModelEliteSet}{$\mat{X}, \mat{Y}, \M, \e, m, m_\text{elite}$}
    % Fit to entire population!
    \State $\surrogate \leftarrow \textproc{GaussianProcess}(\mat{X}, \mat{Y}, \text{kernel}, \text{optimizer})$ % Squared exponential, NelderMead
    \State $\mat{X}_\text{m} \sim \M(\;\cdot \mid \vec{\theta}_k)$ where $\mat{X}_\text{m} \in \R^{10m}$
    \State $\mathbf{\hat{\mat{Y}}}_\text{m} \leftarrow \surrogate(\vec{x}_\text{m})$ for $\vec{x}_\text{m} \in \mat{X}_\text{m}$
    \State $\e_\text{model} \leftarrow$ store top $10m_\text{elite}$ from $\mathbf{\hat{\mat{Y}}}_\text{m}$
    \State $\e_\text{sub} \leftarrow \textproc{SubEliteSet}(\surrogate, \M, \e)$
    \State $\bfE \leftarrow \{ \e \} \cup \{ \e_\text{model} \} \cup \{ \e_\text{sub} \}$ \algorithmiccomment{elite set}
    \State \Return $\bfE$
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:model_elite_set} Modeling elite set.}
\end{algorithm}"""; num=4, caption="Modeling elite set.")

# ╔═╡ 63a05641-aa39-4e4f-9022-f61cdd232549


# ╔═╡ a4fdee5f-0eeb-4da9-9e79-daff1bf9d72d


# ╔═╡ ee3f95ea-b896-4dff-b827-11eb66280c40
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{SubEliteSet}{$\surrogate, \M, \e$}
    \State $\e_\text{sub} \leftarrow \emptyset$
    \State $\m \leftarrow \{ e_x \in \e \mid \Normal(e_x, \M.\Sigma) \}$
    \For {$\m_i \in \m$}
        \State $\m_i \leftarrow \textproc{CrossEntropyMethod}(\surrogate, \m_i \mid \theta_{\text{CE}})$
        \State $\e_\text{sub} \leftarrow \{\e_\text{sub}\} \cup \{\textproc{Best}(\m_i)\}$
    \EndFor
    \State \Return $\e_\text{sub}$
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:sub_elite_set} Subcomponent elite set.}
\end{algorithm}"""; num=5, caption="Subcomponent elite set.")

# ╔═╡ d207343d-494b-4590-a049-671c3a86dbc8


# ╔═╡ 96b6a5e1-0788-494f-a3ee-fb34ae85d89e
@subsection "Cross-Entropy Mixture Method"

# ╔═╡ a337e1c4-5a8d-4f7e-b192-44487a9ae348


# ╔═╡ 64d17042-c899-4195-b34f-049f782b7c07
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{Fit}{$\M, \m, \bfE$}
    \State $\M \leftarrow \operatorname{Mixture}( \m )$
    \State $\mathbf{\hat{𝛉}} \leftarrow \textproc{ExpectationMaximization}(\M, \bfE)$
    \State \Return $\M(\;\cdot \mid \mathbf{\hat{𝛉}})$
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:ce_mixture_fit} Fitting mixture models (used by CE-mixture).}
\end{algorithm}"""; num=6, caption="Fitting mixture models (used by CE-mixture).")

# ╔═╡ a10435a4-22ab-49e4-923c-ff1af1a75f8a


# ╔═╡ 72ea16c4-1d97-4cc5-a759-be7e65097b24
@subsection "Evaluation Scheduling"

# ╔═╡ c7cc0515-f25d-465d-916f-9db0f47b1cb5


# ╔═╡ ce75e391-89a7-4b04-a110-f8c59700c9a0
alg(raw"""
\begin{algorithm}[ht]
  \begin{algorithmic}
  \Function{EvaluationSchedule}{$k, k_\text{max}$}
    \State $G \sim \Geo(p)$
    \State $N_\text{max} \leftarrow k_\text{max} \cdot m$
    \State $m \leftarrow \round{N_\text{max} \cdot p_G(k)}$
    \If{$k = k_\text{max}$}
        \State $s \leftarrow \displaystyle\sum_{i=1}^{k_\text{max}-1} \round{N_\text{max} \cdot p_G(i)}$
        \State $m \leftarrow \min(N_\text{max} - s, N_\text{max} - m)$
    \EndIf
    \State $m_\text{elite} \leftarrow \min(m_\text{elite}, m)$
    \State \Return ($m, m_\text{elite}$) 
  \EndFunction
  \end{algorithmic}
  \caption{\label{alg:evaluation_schedule} Evaluation schedule using a Geometric distr.}
\end{algorithm}"""; num=7, caption="Evaluation schedule using a Geometric distr.")

# ╔═╡ a989f1c8-6812-429b-83e0-0579b0d2c086


# ╔═╡ 9a218c51-4c33-496c-bdce-f1b12284b647
@section "Experiments"

# ╔═╡ 2fa1380e-f010-43b9-92d6-621360b4b2b7
@subsection "Test Objective Function Generation"

# ╔═╡ 581f5aaa-2c67-4436-9d5d-41936a7f6712
md" $\text{decay} =$ $(@bind decay CheckBox(default=true))"

# ╔═╡ a7689b9d-b0a6-4a11-8924-b30afad83829
@bind reset Button("Reset")

# ╔═╡ a67149d9-b9b7-4799-9d8c-e42b45aa33a0
begin
	reset
	md" $\eta =$ $(@bind η Slider(0.1:0.1:6, show_value=true, default=2))"
end

# ╔═╡ 31294620-050a-45a6-9e0c-50613ee55596
begin
	reset
	md" $\delta =$ $(@bind δ Slider(0.1:0.1:6, show_value=true, default=2))"
end

# ╔═╡ e131ff75-18dd-4262-a50a-f12d5cc8dbd0
begin
	reset
	md" $\sigma =$ $(@bind σ Slider(0.1:0.1:6, show_value=true, default=3))"
end

# ╔═╡ d760f66a-4d25-495b-9471-2c9130065c1e
@subsection "Experimental Setup"

# ╔═╡ 34260ef3-3583-408d-a7d7-cffa340ef52d
@subsubsection "Algorithmic Experiments"

# ╔═╡ 895d8f0a-b325-4632-b7ca-337e1d04383d
@subsubsection "Scheduling Experiments"

# ╔═╡ 3319e698-0905-4b5e-84bd-01885adb2a75
@subsection "Results and Analysis"

# ╔═╡ 7c139b46-a97f-4d2f-bfcb-afdcf9011db1
md"""
| Experiment | Algorithm | Runtime | $\bar{b}_v$ | $\bar{b}_d$ |
| :--------: | :-------- | ------: | ----------: | ----------: |
| | CE-method | $\mathbf{0.029}$ s | $-0.0134$ | $23.48$ |
| 1A | CE-surrogate | $1.470$ s | $\mathbf{-0.0179}$ | $\mathbf{12.23}$ |
| | CE-mixture | $9.170$ s | $-0.0169$ | $16.87$ |
| —————— | —————————— | —————— | —————— | —————— |
| | CE-method | $\mathbf{0.046}$ s | $-0.0032$ | $138.87$ |
| 1B | CE-surrogate | $\mathbf{11.820}$ s | $\mathbf{-0.0156}$ | $\mathbf{18.24}$ |
| | CE-mixture | $2.570$ s | $-0.0146$ | $22.17$ |
| —————— | —————————— | —————— | —————— | —————— |
| | CE-method | $\mathbf{0.052}$ s | $-0.0065$ | $43.14$ |
| 1C | CE-surrogate | $0.474$ s | $\mathbf{-0.0156}$ | $\mathbf{17.23}$ |
| | CE-mixture | $\mathbf{2.570}$ s | $-0.0146$ | $22.17$ |
| —————— | —————————— | —————— | —————— | —————— |
| | CE-surrogate, $\operatorname{Uniform}$ | — | $\mathbf{-0.0193}$ | $\mathbf{8.53}$ |
| 2 | CE-surrogate, $\operatorname{Geo}(0.1)$ | — | $-0.0115$ | $25.35$ |
| 2 | CE-surrogate, $\operatorname{Geo}(0.2)$ | — | $-0.0099$ | $27.59$ |
| 2 | CE-surrogate, $\operatorname{Geo}(0.3)$ | — | $-0.0089$ | $30.88$ |
| —————— | —————————— | —————— | —————— | —————— |
| | |  | $\mathbf{x}^* \approx -0.0220$ |  |
"""

# ╔═╡ 5359d680-1780-4741-8038-8c33f940790a
@section "Conclusion"

# ╔═╡ 788972e1-6fcc-479b-9a9f-d2ca747820f8
@star "Appendix"

# ╔═╡ ebbcb72a-f6f8-449e-b1ab-47c9756ad50b
md"""
The indicator function $\mathbb{1}$ is defined as:

$$\mathbb{1}(b) = \begin{cases}
1 & \text{if } b \\
0 & \text{otherwise}
\end{cases}$$
"""

# ╔═╡ 09c4997f-22c5-41fd-945e-d82dea5d9489
𝕀(b) = b ? 1 : 0

# ╔═╡ 6b053d90-020e-4c6d-9488-f6456704a112
function sierra(; 𝛍=[0,0], σ=3, 𝐬=[+σ,-σ], δ=2, η=6, decay=true)
    𝚺 = [σ 0.0; 0.0 σ]
    decay = 𝕀(decay)
    origin = [0.0, 0.0]
    𝐒 = MvNormal[MvNormal(𝛍, 𝚺/(σ*η))]

    for g in [[+δ, +δ], [+δ, -δ], [-δ, +δ], [-δ, -δ]]
        for (i,𝐩) in enumerate([origin, [1, 1], [2, 0], [3, 1], [0, 2], [1, 3]])
            for s in 𝐬
                push!(𝐒, MvNormal(g + s*𝐩 + 𝛍, i^decay/η * 𝚺))
            end
        end
    end

    𝐌 = MixtureModel(𝐒)
	return (x,y)->-pdf(𝐌, [x,y])
end

# ╔═╡ a0aa94e6-c173-4ed0-945a-9640739014e3
@references md"""
1. R. J. Moss, A. Corso, J. Caers, and M. J. Kochenderfer. Beta Zero: Belief-State Planning for Long Horizon POMDPs using Learned Approximations. _Reinforcement Learning Journal_, 1(1), 2024.


2. R. J. Moss, A. Jamgochian, J. Fischer, A. Corso, and M. J. Kochenderfer. ConstrainedZero: Chance-Constrained POMDP Planning Using Learned Probabilistic Failure Surrogates and Adaptive Safety Constraints. _International Joint Conference on Artificial Intelligence (IJCAI)_, 2024.
"""

# ╔═╡ 02c17265-1f95-4858-aabe-ab6784f7cbac
md"""
---
"""

# ╔═╡ 4968a4e8-345f-4b4f-b0de-ff221781f57b
begin
	latex_trigger = true # NOTE: move to `paper` or into package.

	import PlutoPapers: @latex_str

	md"`latex_trigger`"
end

# ╔═╡ 5528a0f4-3175-425b-98ab-5e82a555555e
latex"""
The cross-entropy (CE) method is a probabilistic optimization approach that attempts to iteratively fit a distribution to elite samples from an initial input distribution \cite{rubinstein2004cross,rubinstein1999cross}.
The goal is to estimate a rare-event probability by minimizing the \textit{cross-entropy} between the two distributions \cite{de2005tutorial}.
The CE-method has gained popularity in part due to its simplicity in implementation and straightforward derivation.
The technique uses \textit{importance sampling} which introduces a proposal distribution over the rare-events to sample from then re-weights the posterior likelihood by the \textit{likelihood ratio} of the true distribution over the proposal distribution.

There are a few key assumptions that make the CE-method work effectively.
Through random sampling, the CE-method assumes that there are enough objective function evaluations to accurately represent the objective. 
This may not be a problem for simple applications, but can be an issue for computationally expensive objective functions. 
Another assumption is that the initial parameters of the input distribution are wide enough to cover the design space of interest. For the case with a multivariate Gaussian distribution, this corresponds to an appropriate mean and wide covariance.
In rare-event simulations with many local minima, the CE-method can fail to find a global minima especially with sparse objective function evaluations.

This work aims to address the key assumptions of the CE-method.
We introduce variants of the CE-method that use surrogate modeling to approximate the objective function, thus updating the belief of the underlying objective through estimation.
As part of this approach, we introduce evaluation scheduling techniques to reallocate true objective function calls earlier in the optimization when we know the covariance will be large.
The evaluation schedules can be based on a distribution (e.g., the Geometric distribution) or can be prescribed manually depending on the problem.
We also use a Gaussian mixture model representation of the prior distribution as a method to explore competing local optima.
While the use of Gaussian mixture models in the CE-method is not novel, we connect the use of mixture models and surrogate modeling in the CE-method.
This connection uses each elite sample as the mean of a component distribution in the mixture, optimized through a subroutine call to the standard CE-method using the learned surrogate model.
To test our approach, we introduce a parameterized test objective function called \textit{sierra}.
The sierra function is built from a multivariate Gaussian mixture model with many local minima and a single global minimum.
Parameters for the sierra function allow control over both the spread and distinction of the minima.
Lastly, we provide an analysis of the weak areas of the CE-method compared to our proposed variants.
"""

# ╔═╡ 7e24b7fe-4ed6-4a19-bc94-81c0592d07da
latex"""
The cross-entropy method is popular in the fields of operations research, machine learning, and optimization \cite{kochenderfer2015decision,Kochenderfer2019}.
The combination of the cross-entropy method, surrogate modeling, and mixture models has been explored in other work \cite{bardenet2010surrogating}. 
The work in \cite{bardenet2010surrogating} proposed an adaptive grid approach to accelerate Gaussian-process-based surrogate modeling using mixture models as the prior in the cross-entropy method. They showed that a mixture model performs better than a single Gaussian when the objective function is multimodal.
Our work differs in that we augment the ``elite'' samples both by an approximate surrogate model and by a subroutine call to the CE-method using the learned surrogate model.
Other related work use Gaussian processes and a modified cross-entropy method for receding-horizon trajectory optimization \cite{tan2018gaussian}.
Their cross-entropy method variant also incorporates the notion of exploration in the context of path finding applications.
An approach based on \textit{relative entropy}, described in \cref{sec:background_ce}, proposed a model-based stochastic search that seeks to minimize the relative entropy \cite{NIPS2015_5672}. They also explore the use of a simple quadratic surrogate model to approximate the objective function.
Prior work that relate cross-entropy-based adaptive importance sampling with Gaussian mixture models show that a mixture model require less objective function calls than a naïve Monte Carlo or standard unimodal cross-entropy-based importance sampling method \cite{kurtz2013cross,wang2016cross}.
"""
# ï

# ╔═╡ f91a6354-6cfe-446c-b449-871d05be0796
latex"""
Before understanding the cross-entropy method, we first must understand the notion of \textit{cross-entropy}.
Cross-entropy is a metric used to measure the distance between two probability distributions, where the distance may not be symmetric \cite{de2005tutorial}.
The distance used to define cross-entropy is called the \textit{Kullback-Leibler (KL) distance} or \textit{KL divergence}.
The KL distance is also called the \textit{relative entropy}, and we can use this to derive the cross-entropy.
Formally, for a random variable $\mat{X} = (X_1, \ldots, X_n)$ with a support of $\mathcal{X}$, the KL distance between two continuous probability density functions $f$ and $g$ is defined to be:
\begin{align*}
    \mathcal{D}(f, g) &= \E_f\left[\log \frac{f(\vec{X})}{g(\vec{X})} \right]\\
                      &= \int\limits_{\vec{x} \in \mathcal{X}} f(\vec{x}) \log f(\vec{x}) d\vec{x} - \int\limits_{\vec{x} \in \mathcal{X}} f(\vec{x}) \log g(\vec{x}) d\vec{x}
\end{align*}
We denote the expectation of some function with respect to a distribution $f$ as $\E_f$.
Minimizing the KL distance $\mathcal{D}$ between our true distribution $f$ and our proposal distribution $g$ parameterized by $\vec{\theta}$, is equivalent to choosing $\vec\theta$ that minimizes the following, called the \textit{cross-entropy}:
\begin{align*}
    H(f,g) &= H(f) + \mathcal{D}(f,g)\\
           &= -\E_f[\log g(\vec{X})] \tag{using KL distance}\\
           &= - \int\limits_{\vec{x} \in \mathcal{X}} f(\vec{x}) \log g(\vec{x} \mid \vec{\theta}) d\vec{x}
\end{align*}
where $H(f)$ denotes the entropy of the distribution $f$ (where we conflate entropy and continuous entropy for convenience).
This assumes that $f$ and $g$ share the support $\mathcal{X}$ and are continuous with respect to $\vec{x}$.
The minimization problem then becomes:
\begin{equation}
\begin{aligned}
    \minimize_{\vec{\theta}} & & - \int\limits_{\vec{x} \in \mathcal{X}} f(\vec{x}) \log g(\vec{x} \mid \vec{\theta}) d\vec{x}
\end{aligned}
\end{equation}
Efficiently finding this minimum is the goal of the cross-entropy method algorithm.
"""

# ╔═╡ 0d293ee9-65d2-45bd-ba66-75b9ccf4eef9
latex"""
Using the definition of cross-entropy, intuitively the \textit{cross-entropy method} (CEM or CE-method) aims to minimize the cross-entropy between the unknown true distribution $f$ and a proposal distribution $g$ parameterized by $\vec\theta$.
This technique reformulates the minimization problem as a probability estimation problem, and uses adaptive importance sampling to estimate the unknown expectation \cite{de2005tutorial}.
The cross-entropy method has been applied in the context of both discrete and continuous optimization problems \cite{rubinstein1999cross,kroese2006cross}.


The initial goal is to estimate the probability 
\begin{align*}
    \ell = P_{\vec{\theta}}(S(\vec{x}) \ge \gamma)
\end{align*}
where $S$ can the thought of as an objective function of $\vec{x}$, and $\vec{x}$ follows a distribution defined by $g(\vec{x} \mid \vec{\theta})$.
We want to find events where our objective function $S$ is above some threshold $\gamma$.
We can express this unknown probability as the expectation
\begin{align} \label{eq:expect}
    \ell = \E_{\vec{\theta}}[\mathbbm{1}_{(S(\vec{x}) \ge \gamma)}]
\end{align}
where $\mathbbm{1}$ denotes the indicator function.
A straightforward way to estimate \cref{eq:expect} can be done through Monte Carlo sampling.
But for rare-event simulations where the probability of a target event occurring is relatively small, this estimate becomes inadequate.
The challenge of the minimization in \cref{eq:min} then becomes choosing the density function for the true distribution $f(\vec{x})$. 
Importance sampling tells us that the optimal importance sampling density can be reduced to
\begin{align*}
    f^*(\vec{x}) = \frac{\mathbbm{1}_{(S(\vec{x}) \ge \gamma)}g(\vec{x} \mid \vec{\theta})}{\ell}
\end{align*}
thus resulting in the optimization problem:
\begin{align*}
    \vec{\theta}_g^* &= \argmin_{\vec{\theta}_g} - \int\limits_{\vec{x} \in \mathcal{X}} f^*(\vec{x})\log g(\vec{x} \mid \vec{\theta}_g) d\vec{x}\\
                   &= \argmin_{\vec{\theta}_g} - \int\limits_{\vec{x} \in \mathcal{X}} \frac{\mathbbm{1}_{(S(\vec{x}) \ge \gamma)}g(\vec{x} \mid \vec{\theta})}{\ell}\log g(\vec{x} \mid \vec{\theta}_g) d\vec{x}
\end{align*}
Note that since we assume $f$ and $g$ belong to the same family of distributions, we get that $f(\vec{x}) = g(\vec{x} \mid \vec{\theta}_g)$.
Now notice that $\ell$ is independent of $\vec{\theta}_g$, thus we can drop $\ell$ and get the final optimization problem of:
\begin{align} \label{eq:opt}
    \vec{\theta}_g^* &= \argmin_{\vec{\theta}_g} - \int\limits_{\vec{x} \in \mathcal{X}} \mathbbm{1}_{(S(\vec{x}) \ge \gamma)}g(\vec{x} \mid \vec{\theta}) \log g(\vec{x} \mid \vec{\theta}_g) d\vec{x}\\\nonumber
                   &= \argmin_{\vec{\theta}_g} - \E_{\vec{\theta}}[ \mathbbm{1}_{(S(\vec{x}) \ge \gamma)} \log g(\vec{x} \mid \vec{\theta}_g)]
\end{align}

The CE-method uses a multi-level algorithm to estimate $\vec{\theta}_g^*$ iteratively.
The parameter $\vec{\theta}_k$ at iteration $k$ is used to find new parameters $\vec{\theta}_{k^\prime}$ at the next iteration $k^\prime$.
The threshold $\gamma_k$ becomes smaller that its initial value, thus artificially making events \textit{less rare} under $\vec{X} \sim g(\vec{x} \mid \vec{\theta}_k)$.

In practice, the CE-method algorithm requires the user to specify a number of \textit{elite} samples $m_\text{elite}$ which are used when fitting the new parameters for iteration $k^\prime$.
Conveniently, if our distribution $g$ belongs to the \textit{natural exponential family} then the optimal parameters can be found analytically \cite{Kochenderfer2019}. For a multivariate Gaussian distribution parameterized by $\vec{\mu}$ and $\mat{\Sigma}$, the optimal parameters for the next iteration $k^\prime$ correspond to the maximum likelihood estimate (MLE):
\begin{align*}
    \vec{\mu}_{k^\prime} &= \frac{1}{m_\text{elite}} \sum_{i=1}^{m_\text{elite}} \vec{x}_i\\
    \vec{\Sigma}_{k^\prime} &= \frac{1}{m_\text{elite}} \sum_{i=1}^{m_\text{elite}} (\vec{x}_i - \vec{\mu}_{k^\prime})(\vec{x}_i - \vec{\mu}_{k^\prime})^\top
\end{align*}

The cross-entropy method algorithm is shown in \cref{alg:cem}.
For an objective function $S$ and input distribution $g$, the CE-method algorithm will run for $k_\text{max}$ iterations.
At each iteration, $m$ inputs are sampled from $g$ and evaluated using the objective function $S$.
The sampled inputs are denoted by $\mat{X}$ and the evaluated values are denoted by $\mat{Y}$.
Next, the top $m_\text{elite}$ samples are stored in the elite set $\e$, and the distribution $g$ is fit to the elites.
This process is repeated for $k_\text{max}$ iterations and the resulting parameters $\vec{\theta}_{k_\text{max}}$ are returned.
Note that a variety of input distributions for $g$ are supported, but we focus on the multivariate Gaussian distribution and the Gaussian mixture model in this work.
"""

# ╔═╡ fd9d712f-aab5-495c-99c6-2f4e2f4f2ade
latex"""
A standard Gaussian distribution is \textit{unimodal} and can have trouble generalizing over data that is \textit{multimodal}.
A \textit{mixture model} is a weighted mixture of component distributions used to represent continuous multimodal distributions \cite{kochenderfer2015decision}.
Formally, a Gaussian mixture model (GMM) is defined by its parameters $\vec{\mu}$ and $\mat{\Sigma}$ and associated weights $\w$ where $\sum_{i=1}^n w_i = 1$. We denote that a random variable $\mat{X}$ is distributed according to a mixture model as $\mat{X} \sim \operatorname{Mixture}(\vec{\mu}, \vec{\Sigma}, \vec{w})$.
The probability density of the GMM then becomes:
%% Mixture model PDF
\begin{gather*}
    P( \mat{X} = \vec{x} \mid \vec{\mu}, \mat{\Sigma}, \vec{w}) = \sum_{i=1}^n w_i \Normal(\vec{x} \mid \vec{\mu}_i, \mat{\Sigma}_i)
\end{gather*}

To fit the parameters of a Gaussian mixture model, it is well known that the \textit{expectation-maximization (EM)} algorithm can be used \cite{dempster1977maximum,aitkin1980mixture}. 
The EM algorithm seeks to find the maximum likelihood estimate of the hidden variable $H$ using the observed data defined by $E$.
Intuitively, the algorithm alternates between an expectation step (E-step) and a maximization step (M-step) to guarantee convergence to a local minima.
A simplified EM algorithm is provide in \cref{alg:em} for reference and we refer to \cite{dempster1977maximum,aitkin1980mixture} for further reading.
"""

# ╔═╡ 52ae6392-59c1-4b8b-aa77-471945a7cd16
latex"""
In the context of optimization, a surrogate model $\hat{S}$ is used to estimate the true objective function and provide less expensive evaluations.
Surrogate models are a popular approach and have been used to evaluate rare-event probabilities in computationally expensive systems \cite{li2010evaluation,li2011efficient}.
The simplest example of a surrogate model is linear regression.
In this work, we focus on the \textit{Gaussian process} surrogate model.
A Gaussian process (GP) is a distribution over functions that predicts the underlying objective function $S$ and captures the uncertainty of the prediction using a probability distribution \cite{Kochenderfer2019}.
This means a GP can be sampled to generate random functions, which can then be fit to our given data $\mat{X}$.
A Gaussian process is parameterized by a mean function $\m(\mat{X})$ and kernel function $\mat{K}(\mat{X},\mat{X})$, which captures the relationship between data points as covariance values.
We denote a Gaussian process that produces estimates $\hat{\vec{y}}$ as:
\begin{align*}
\hat{\vec{y}} &\sim\mathcal{N}\left(\vec{m}(\mat{X}),\vec{K}(\mat{X},\mat{X})\right)\\
        &= \begin{bmatrix} % Changed `m` to `n`
            \hat{S}(\vec{x}_1), \ldots, \hat{S}(\vec{x}_n)
        \end{bmatrix}
\end{align*}
where
\begin{gather*}
\vec{m}(\mat{X}) = \begin{bmatrix} m(\vec{x}_1), \ldots, m(\vec{x}_n) \end{bmatrix}\\
\vec{K}(\mat{X}, \mat{X}) = \begin{bmatrix}
         k(\vec{x}_1, \vec{x}_1) & \cdots & k(\vec{x}_1, \vec{x}_n)\\
         \vdots & \ddots & \vdots\\
         k(\vec{x}_n, \vec{x}_1) & \cdots & k(\vec{x}_n, \vec{x}_n)
     \end{bmatrix}
\end{gather*}
We use the commonly used zero-mean function $m(\vec{x}_i) = \vec{0}$.
For the kernel function $k(\vec{x}_i, \vec{x}_i)$, we use the squared exponential kernel with variance $\sigma^2$ and characteristic scale-length $\ell$, where larger $\ell$ values increase the correlation between successive data points, thus smoothing out the generated functions. The squared exponential kernel is defined as:
% Isotropic Squared Exponential kernel (covariance): \exp(-\frac{r^2}{2\ell^2})
\begin{align*}
k(\vec{x},\vec{x}^\prime) = \sigma^2\exp\left(- \frac{(\vec{x} - \vec{x}^\prime)^\top(\vec{x} - \vec{x}^\prime)}{2\ell^2}\right)
\end{align*}
We refer to \cite{Kochenderfer2019} for a detailed overview of Gaussian processes and different kernel functions.
"""

# ╔═╡ b217c91c-dd37-428f-8462-752232e1520d
latex"""
We can now describe the cross-entropy method variants introduced in this work.
This section will first cover the main algorithm introduced, the cross-entropy surrogate method (CE-surrogate).
Then we introduce a modification to the CE-surrogate method, namely the cross-entropy mixture method (CE-mixture).
Lastly, we describe various evaluation schedules for redistributing objective function calls over the iterations.
"""

# ╔═╡ 278bf5e2-2891-4a11-bb35-4b9202da94e3
latex"""
The main CE-method variant we introduce is the cross-entropy surrogate method (CE-surrogate).
The CE-surrogate method is a superset of the CE-method, where the differences lie in the evaluation scheduling and modeling of the elite set using a surrogate model.
The goal of the CE-surrogate algorithm is to address the shortcomings of the CE-method when the number of objective function calls is sparse and the underlying objective function $S$ has multiple local minima.

The CE-surrogate algorithm is shown in \cref{alg:ce_surrogate}.
It takes as input the objective function $S$, the distribution $\M$ parameterized by $\vec{\theta}$, the number of samples $m$, the number of elite samples $m_\text{elite}$, and the maximum iterations $k_\text{max}$.
For each iteration $k$, the number of samples $m$ are redistributed through a call to \smallcaps{EvaluationSchedule}, where $m$ controls the number of true objective function evaluations of $S$. % EvaluationSchedule.
Then, the algorithm samples from $\M$ parameterized by the current $\vec{\theta}_k$ given the adjusted number of samples $m$. % and clamped $m_\text{elite}$.
For each sample in $\mat{X}$, the objective function $S$ is evaluated and the results are stored in $\mat{Y}$.
The top $m_\text{elite}$ evaluations from $\mat{Y}$ are stored in $\e$. 
Using all of the current function evaluations $\mat{Y}$ from sampled inputs $\mat{X}$, a modeled elite set $\bfE$ is created to augment the sparse information provided by a low number of true objective function evaluations.
Finally, the distribution $\M$ is fit to the elite set $\bfE$ and the distribution with the final parameters $\vec{\theta}_{k_\text{max}}$ is returned.
"""

# ╔═╡ a0915687-3a7f-482d-b756-7a8ab2a6616c
latex"""
The main difference between the standard CE-method and the CE-surrogate variant lies in the call to \smallcaps{ModelEliteSet}.
The motivation is to use \textit{all} of the already evaluated objective function values $\mat{Y}$ from a set of sampled inputs $\mat{X}$.
This way the expensive function evaluations---otherwise discarded---can be used to build a surrogate model of the underlying objective function.
First, a surrogate model $\surrogate$ is constructed from the samples $\mat{X}$ and true objective function values $\mat{Y}$.
We used a Gaussian process with a specified kernel and optimizer, but other surrogate modeling techniques such as regression with basis functions can be used.
We chose a Gaussian process because it incorporates probabilistic uncertainty in the predictions, which may more accurately represent our objective function, or at least be sensitive to over-fitting to sparse data.
Now we have an approximated objective function $\surrogate$ that we can inexpensively call. 
We sample $10m$ values from the distribution $\M$ and evaluate them using the surrogate model.
We then store the top $10m_\text{elite}$ values from the estimates $\mathbf{\hat{\mat{Y}}}_\text{m}$.
We call these estimated elite values $\e_\text{model}$ the \textit{model-elites}.
The surrogate model is then passed to \smallcaps{SubEliteSet}, which returns more estimates for elite values.
Finally, the elite set $\bfE$ is built from the true-elites $\e$, the model-elites $\e_\text{model}$, and the subcomponent-elites $\e_\text{sub}$.
The resulting concatenated elite set $\bfE$ is returned.
"""

# ╔═╡ 945a7b36-f66c-42f0-ac71-eff2cfd9a0b3
latex"""
To encourage exploration of promising areas of the design space, the algorithm \smallcaps{SubEliteSet} focuses on the already marked true-elites $\e$.
Each elite $e_x \in \e$ is used as the mean of a new multivariate Gaussian distribution with covariance inherited from the distribution $\M$.
The collection of subcomponent distributions is stored in $\m$.
The idea is to use the information given to us by the true-elites to emphasize areas of the design space that look promising.
For each distribution $\m_i \in \m$ we run a subroutine call to the standard CE-method to fit the distribution $\m_i$ using the surrogate model $\surrogate$. 
Then the best objective function value is added to the subcomponent-elite set $\e_\text{sub}$, and after iterating the full set is returned.
Note that we use $\theta_\text{CE}$ to denote the parameters for the CE-method algorithm.
In our case, we recommend using a small $k_\text{max}$ of around $2$ so the subcomponent-elites do not over-fit to the surrogate model but have enough CE-method iterations to tend towards optimal.
"""

# ╔═╡ 877e7c08-e5ff-48ee-9725-cab10bf81e98
latex"""
We refer to the variant of our CE-surrogate method that takes an input \textit{mixture model} $\M$ as the cross-entropy mixture method (CE-mixture).
The CE-mixture algorithm is identical to the CE-surrogate algorithm, but calls a custom \smallcaps{Fit} function to fit a mixture model to the elite set $\bfE$.
The input distribution $\M$ is cast to a mixture model using the subcomponent distributions $\m$ as the components of the mixture.
We use the default uniform weighting for each mixture component.
The mixture model $\M$ is then fit using the expectation-maximization algorithm shown in \cref{alg:em}, and the resulting distribution is returned.
The idea is to use the distributions in $\m$ that are centered around each true-elite as the components of the casted mixture model.
Therefore, we would expect better performance of the CE-mixture method when the objective function has many competing local minima.
Results in \cref{sec:results} aim to show this behavior.
"""

# ╔═╡ b518287e-d5d9-438f-b751-2905d771270d
latex"""
Given the nature of the CE-method, we expect the covariance to shrink over time, thus resulting in a solution with higher confidence.
Yet if each iteration is given the same number of objective function evaluations $m$, there is the potential for elite samples from early iterations dominating the convergence.
Therefore, we would like to redistribute the objective function evaluations throughout the iterations to use more truth information early in the process.
We call these heuristics \textit{evaluation schedules}.
One way to achieve this is to reallocate the evaluations according to a Geometric distribution.
Evaluation schedules can also be ad-hoc and manually prescribed based on the current iteration.

We provide the evaluation schedule we use that follows a Geometric distribution with parameter $p$ in \cref{alg:evaluation_schedule}.
We denote $G \sim \Geo(p)$ to be a random variable that follows a truncated Geometric distribution with the probability mass function $p_G(k) = p(1 - p)^k$ for $k \in \{0, 1, 2, \ldots, k_\text{max}\}$. % Geo(p) PMF
Note the use of the integer rounding function (e.g., $\round{x}$), which we later have to compensate for towards the final iterations.
Results in \cref{sec:results} compare values of $p$ that control the redistribution of evaluations.
"""

# ╔═╡ bd886ee2-21a0-4f12-ba6b-6db00dffe507
latex"""
In this section, we detail the experiments we ran to compare the CE-method variants and evaluation schedules.
We first introduce a test objective function we created to stress the issue of converging to local minima. 
We then describe the experimental setup for each of our experiments and provide an analysis and results.
"""

# ╔═╡ 15c85cdd-8839-4664-866c-73e8f18155cd
latex"""
To stress the cross-entropy method and its variants, we created a test objective function called \textit{sierra} that is generated from a mixture model comprised of $49$ multivariate Gaussian distributions.
We chose this construction so that we can use the negative peeks of the component distributions as local minima and can force a global minimum centered at our desired $\mathbf{\tilde{\vec{\mu}}}$.
The construction of the sierra test function can be controlled by parameters that define the spread of the local minima.
We first start with the center defined by a mean vector $\mathbf{\tilde{\vec{\mu}}}$ and we use a common covariance $\mathbf{\tilde{\mat{\Sigma}}}$:
\begin{align*}
    \mathbf{\tilde{\vec{\mu}}} &= [\mu_1, \mu_2], \quad \mathbf{\tilde{\mat{\Sigma}}} = \begin{bmatrix}\sigma & 0\\ 0 & \sigma \end{bmatrix}
\end{align*}
Next, we use the parameter $\delta$ that controls the clustered distance between symmetric points:
\begin{align*}
    \mat{G} &= \left\{[+\delta, +\delta], [+\delta, -\delta], [-\delta, +\delta], [-\delta, -\delta]\right\}
\end{align*}
We chose points $\mat{P}$ to fan out the clustered minima relative to the center defined by $\mathbf{\tilde{\vec{\mu}}}$:
\begin{align*}
    \mat{P} &= \left\{[0, 0], [1, 1], [2, 0], [3, 1], [0, 2], [1, 3]\right\}
\end{align*}
The vector $\vec{s}$ is used to control the $\pm$ distance to create an `s' shape comprised of minima, using the standard deviation $\sigma$:
$\vec{s} = \begin{bmatrix}+\sigma, -\sigma \end{bmatrix}$.
We set the following default parameters: standard deviation $\sigma=3$, spread rate $\eta=6$, and cluster distance $\delta=2$.
We can also control if the local minima clusters ``decay'', thus making those local minima less distinct (where $\text{decay} \in \{0, 1\})$.
The parameters that define the sierra function are collected into $\vec{\theta} = \langle \mathbf{\tilde{\vec{\mu}}}, \mathbf{\tilde{\mat{\Sigma}}}, \mat{G}, \mat{P}, \vec{s} \rangle$.
Using these parameters, we can define the mixture model used by the sierra function as:
\begin{gather*}
    \Sierra \sim \operatorname{Mixture}\left(\left\{ \vec{\theta} ~\Big|~ \Normal\left(\vec{g} +  s\vec{p}_i + \mathbf{\tilde{\vec{\mu}}},\; \mathbf{\tilde{\mat{\Sigma}}} \cdot i^{\text{decay}}/\eta \right) \right\} \right)\\
    \text{for } (\vec{g}, \vec{p}_i, s) \in (\mat{G}, \mat{P}, \vec{s})
\end{gather*}
We add a final component to be our global minimum centered at $\mathbf{\tilde{\vec{\mu}}}$ and with a covariance scaled by $\sigma\eta$. Namely, the global minimum is $\vec{x}^* = \E[\Normal(\mathbf{\tilde{\vec{\mu}}}, \mathbf{\tilde{\mat{\Sigma}}}/(\sigma\eta))] = \mathbf{\tilde{\vec{\mu}}}$.
We can now use this constant mixture model with $49$ components and define the sierra objective function $\mathcal{S}(\vec{x})$ to be the negative probability density of the mixture at input $\vec{x}$ with uniform weights:

\begin{align*}
    \mathcal{S}(\vec{x}) &= -P(\Sierra = \vec{x}) = -\frac{1}{|\Sierra|}\sum_{j=1}^{n}\Normal(\vec{x} \mid \vec{\mu}_j, \mat{\Sigma}_j)
\end{align*}
An example of six different objective functions generated using the sierra function are shown in \cref{fig:sierra}, sweeping over the spread rate $\eta$, with and without decay.
"""

# ╔═╡ 2fd47be7-3763-49e0-a3f9-c043ce351d79
latex"""
Experiments were run to stress a variety of behaviors of each CE-method variant.
The experiments are split into two categories: algorithmic and scheduling.
The algorithmic category aims to compare features of each CE-method variant while holding common parameters constant (for a better comparison).
While the scheduling category experiments with evaluation scheduling heuristics."""

# ╔═╡ aefedada-315c-46d3-a443-8627a81f2287
latex"""
Because the algorithms are stochastic, we run each experiment with 50 different random number generator seed values.
To evaluate the performance of the algorithms in their respective experiments, we define three metrics.
First, we define the average ``optimal'' value $\bar{b}_v$ to be the average of the best so-far objective function value (termed ``optimal'' in the context of each algorithm). Again, we emphasize that we average over the 50 seed values to gather meaningful statistics.
Another metric we monitor is the average distance to the true global optimal $\bar{b}_d = \norm{\vec{b}_{\vec{x}} - \vec{x}^*}$, where $\vec{b}_{\vec{x}}$ denotes the $\vec{x}$-value associated with the ``optimal''.
We make the distinction between these metrics to show both ``closeness'' in \textit{value} to the global minimum and ``closeness'' in the \textit{design space} to the global minimum.
Our final metric looks at the average runtime of each algorithm, noting that our goal is to off-load computationally expensive objective function calls to the surrogate model.

For all of the experiments, we use a common setting of the following parameters for the sierra test function (shown in the top-right plot in \cref{fig:sierra}):
\begin{equation*}
    (\mathbf{\tilde{\vec{\mu}}} =[0,0],\; \sigma=3,\; \delta=2,\; \eta=6,\; \text{decay} = 1)
\end{equation*}
"""

# ╔═╡ 3035ba16-0e9c-44bf-bdae-e61a1c763905
latex"""
We run three separate algorithmic experiments, each to test a specific feature.
For our first algorithmic experiment (1A), we want to test each algorithm when the user-defined mean is centered at the global minimum and the covariance is arbitrarily wide enough to cover the design space.
Let $\M$ be a distribution parameterized by $\vec{\theta} = (\vec{\mu}, \mat{\Sigma})$, and for experiment (1A) we set the following:
% CE-mixture mean and covariance (1A)
\begin{equation*}
    \vec\mu^{(\text{1A})} = [0, 0] \qquad
    \mat\Sigma^{(\text{1A})} = \begin{bmatrix}
        200 & 0\\
        0 & 200
    \end{bmatrix}
\end{equation*}

For our second algorithmic experiment (1B), we test a mean that is far off-centered with a wider covariance:
% CE-mixture mean and covariance (1B)
\begin{equation*}
    \vec\mu^{(\text{1B})} = [-50, -50] \qquad
    \mat\Sigma^{(\text{1B})} = \begin{bmatrix}
        2000 & 0\\
        0 & 2000
    \end{bmatrix}
\end{equation*}
This experiment is used to test the ``exploration'' of the CE-method variants introduced in this work.
In experiments (1A) and (1B), we set the following common parameters across each CE-method variant:
%% CE-mixture hyperparameter settings
\begin{equation*}
    (k_\text{max} = 10,\; m=10,\; m_\text{elite}=5)^{(\text{1A,1B})}
\end{equation*}
This results in $m\cdot k_\text{max} = 100$ objective function evaluations, which we define to be \textit{relatively} low.

For our third algorithmic experiment (1C), we want to test how each variant responds to an extremely low number of function evaluations.
This sparse experiment sets the common CE-method parameters to:
% CE-method params (1C)
\begin{equation*}
    (k_\text{max} = 10,\; m=5,\; m_\text{elite}=3)^{(\text{1C})}
\end{equation*}
This results in $m\cdot k_\text{max} = 50$ objective function evaluations, which we defined to be \textit{extremely} low.
We use the same mean and covariance defined for experiment (1A):
\begin{equation*}
    \vec\mu^{(\text{1C})} = [0, 0] \qquad
    \mat\Sigma^{(\text{1C})} = \begin{bmatrix}
        200 & 0\\
        0 & 200
    \end{bmatrix}
\end{equation*}
"""

# ╔═╡ 969497c9-8973-4abb-a798-08a348548c66
latex"""
In our final experiment (2), we test the evaluation scheduling heuristics which are based on the Geometric distribution.
We sweep over the parameter $p$ that determines the Geometric distribution which controls the redistribution of objective function evaluations.
In this experiment, we compare the CE-surrogate methods using the same setup as experiment (1B), namely the far off-centered mean.
We chose this setup to analyze exploration schemes when given very little information about the true objective function.
"""

# ╔═╡ a2b79da1-0279-4479-a50e-a15f076931b1
latex"""
\Cref{fig:experiment_1a} shows the average value of the current optimal $\bar{b}_v$ for the three algorithms for experiment (1A). 
One standard deviation is plotted in the shaded region.
Notice that the standard CE-method converges to a local minima before $k_\text{max}$ is reached.
Both CE-surrogate method and CE-mixture stay below the standard CE-method curve, highlighting the mitigation of convergence to local minima.
Minor differences can be seen between CE-surrogate and CE-mixture, differing slightly towards the tail in favor of CE-surrogate.
The average runtime of the algorithms along with the performance metrics are shown together for each experiment in \cref{tab:results}.
"""

# ╔═╡ e615c23a-9e39-4e98-815a-a21bf2eb8b7b
latex"""
An apparent benefit of the standard CE-method is in its simplicity and speed.
As shown in \cref{tab:results}, the CE-method is the fastest approach by about 2-3 orders of magnitude compared to CE-surrogate and CE-mixture.
The CE-mixture method is notably the slowest approach.
Although the runtime is also based on the objective function being tested, recall that we are using the same number of true objective function calls in each algorithm, and the metrics we are concerned with in optimization are to minimize $\bar{b}_v$ and $\bar{b}_d$.
We can see that the CE-surrogate method consistently out performs the other methods.
Surprisingly, a uniform evaluation schedule performs the best even in the sparse scenario where the initial mean is far away from the global optimal.

When the initial mean of the input distribution is placed far away from the global optimal, the CE-method tends to converge prematurely as shown in \cref{fig:experiment_1b}.
This scenario is illustrated in \cref{fig:example_1b}.
We can see that both CE-surrogate and CE-mixture perform well in this case.

Given the same centered mean as before, when we restrict the number of objective function calls even further to just 50 we see interesting behavior.
Notice that the results of experiment (1C) shown in \cref{fig:experiment_1c} follow a curve closer to the far away mean from experiment (1B) than from the same setup as experiment (1A). Also notice that the CE-surrogate results cap out at iteration 9 due to the evaluation schedule front-loading the objective function calls, thus leaving none for the final iteration (while still maintaining the same total number of evaluations of 50).
"""

# ╔═╡ 638caaa8-d394-4bb9-b22b-da90f9e0e911
latex"""
We presented variants of the popular cross-entropy method for optimization of objective functions with multiple local minima.
Using a Gaussian processes-based surrogate model, we can use the same number of true objective function evaluations and achieve better performance than the standard CE-method on average.
We also explored the use of a Gaussian mixture model to help find global minimum in multimodal objective functions.
We introduce a parameterized test objective function with a controllable global minimum and spread of local minima.
Using this test function, we showed that the CE-surrogate algorithm achieves the best performance relative to the standard CE-method, each using the same number of true objective function evaluations.
"""

# ╔═╡ 6aa3b45b-b2da-48db-9a6b-62eedd2dd698
function Interp2D(data, factor)    
    IC = CubicSplineInterpolation((axes(data,1), axes(data,2)), data)

    finerx = LinRange(firstindex(data,1), lastindex(data,1), size(data,1) * factor)
    finery = LinRange(firstindex(data,2), lastindex(data,2), size(data,2) * factor)
    nx = length(finerx)
    ny = length(finery)

    data_interp = Array{Float64}(undef,nx,ny)
    for i in 1:nx, j in 1:ny
        data_interp[i,j] = IC(finerx[i],finery[j])
    end

    return finerx, finery, data_interp
end

# ╔═╡ 54d99bab-4dd0-42d9-b6a6-5823dbd1ba97
figure(begin
	viridis_r = cgrad(:viridis, rev=true)
	plot(;
		# xlims=(-15, 15),
		# ylims=(-15, 15),
		ratio=1,
		colorbar=false,
		axis=[],
	)
	f = sierra(; η, decay, δ, σ)
	X = Y = range(-15, 15, 25)
	Z = [f(x,y) for y in Y, x in X]
	X′, Y′, Z′ = Interp2D(Z, 16)
	heatmap!(X′, Y′, Z′, color=viridis_r)
	xlims!(ylims()...)
end; caption="Example test objective function generated using the sierra function.")

# ╔═╡ 9c7460f8-b648-4ad4-99bc-ada7fa4afa84
Markdown.MD(
	md"`DarkModeIndicator`",
	md"$(@bind dark_mode DarkModeIndicator())")

# ╔═╡ dc436e60-b1f3-4d17-bb62-76adea32d633
LocalResource(joinpath(@__DIR__, "..", "media", "cem-variants$(dark_mode ? "-dark" : "").png"))

# ╔═╡ f14faaa3-e685-4955-8292-26d4bbc2aaf3
plot_default(; dark_mode); md"> _`Plots` defaults_"

# ╔═╡ 60e7f3d0-248f-4fa0-bb02-1e1753fdee66
html"""
	<style>
		.styled-button {
			background-color: var(--pluto-output-color);
			color: var(--pluto-output-bg-color);
			border: none;
			padding: 10px 20px;
			border-radius: 5px;
			cursor: pointer;
			font-family: Alegreya Sans, Trebuchet MS, sans-serif;
		}
	</style>

	<script>
	const buttons = document.querySelectorAll('input[type="button"]');
	buttons.forEach(button => button.classList.add('styled-button'));
	</script>

	<p><code>styled buttons</code></p>
"""

# ╔═╡ aa5c658b-421f-4cbd-b7bd-5da6582ccff7
Markdown.MD(
	md"$(@hide_all_cells)",
	md"`@hide_all_cells`")

# ╔═╡ 65bc0f87-c726-4026-8a7f-bbdb70e0349e
Markdown.MD(
	# md"$(@show_all_cells)",
	md"`@show_all_cells`")

# ╔═╡ Cell order:
# ╟─9fa5f299-1420-42db-8a02-4f50f79095c2
# ╟─2ab1b89c-d1cd-4967-89f3-5767da8acb5d
# ╟─fb1bcfb6-fe57-4134-8bbd-6c9bb16e29d4
# ╟─735b5dad-50a4-40b0-a10f-1d8aae7a6c03
# ╟─5528a0f4-3175-425b-98ab-5e82a555555e
# ╟─2fade324-1bdd-4398-a484-e6b30a7f4074
# ╟─7e24b7fe-4ed6-4a19-bc94-81c0592d07da
# ╟─b6f26239-b73d-495a-a8d7-12a04253d064
# ╟─d78afeaa-415a-4075-adbe-9f810b09eb0a
# ╟─fde41ba9-a538-440c-ac87-1ae36e266a48
# ╟─f91a6354-6cfe-446c-b449-871d05be0796
# ╟─000e9367-d888-49d3-8b5a-9b520e58c549
# ╟─0d293ee9-65d2-45bd-ba66-75b9ccf4eef9
# ╟─5ba87ec2-3dd0-48fe-909f-a404ae79b1dd
# ╟─8abb278a-42fb-4536-80a4-33de4623f403
# ╟─96a75973-f078-4c90-bb3b-11eeb9579a37
# ╟─0c975dcc-2f52-4999-b72e-184e9c42d3ce
# ╟─fd9d712f-aab5-495c-99c6-2f4e2f4f2ade
# ╟─7a61aa58-6f66-4869-9310-5d353101b4f2
# ╟─37af29bb-85bc-4581-bdc8-0d1274ab2501
# ╟─738eeac7-a92d-406d-bb08-5a17b6c801e5
# ╟─edb7636c-09b9-42ed-8f8e-c7f14c4d95e4
# ╟─52ae6392-59c1-4b8b-aa77-471945a7cd16
# ╟─3d4f2127-d373-4286-a87f-22150893b561
# ╟─b217c91c-dd37-428f-8462-752232e1520d
# ╟─e275b803-2d90-41ac-a7ec-0789e42b69a2
# ╟─278bf5e2-2891-4a11-bb35-4b9202da94e3
# ╟─740a134f-3835-4a59-b261-8036f9274dda
# ╟─ecfc4a73-2530-4bd0-9f24-005c8bf154bb
# ╟─4590eedc-bb30-47bf-a2f0-44adc7924131
# ╟─a0915687-3a7f-482d-b756-7a8ab2a6616c
# ╟─e2d30e72-1da3-4d83-8b7b-ae85e23e1c3d
# ╟─99b6cb8d-b0dc-4517-993a-912640531d19
# ╟─63a05641-aa39-4e4f-9022-f61cdd232549
# ╟─945a7b36-f66c-42f0-ac71-eff2cfd9a0b3
# ╟─a4fdee5f-0eeb-4da9-9e79-daff1bf9d72d
# ╟─ee3f95ea-b896-4dff-b827-11eb66280c40
# ╟─d207343d-494b-4590-a049-671c3a86dbc8
# ╟─96b6a5e1-0788-494f-a3ee-fb34ae85d89e
# ╟─877e7c08-e5ff-48ee-9725-cab10bf81e98
# ╟─a337e1c4-5a8d-4f7e-b192-44487a9ae348
# ╟─64d17042-c899-4195-b34f-049f782b7c07
# ╟─a10435a4-22ab-49e4-923c-ff1af1a75f8a
# ╟─72ea16c4-1d97-4cc5-a759-be7e65097b24
# ╟─b518287e-d5d9-438f-b751-2905d771270d
# ╟─c7cc0515-f25d-465d-916f-9db0f47b1cb5
# ╟─ce75e391-89a7-4b04-a110-f8c59700c9a0
# ╟─a989f1c8-6812-429b-83e0-0579b0d2c086
# ╟─9a218c51-4c33-496c-bdce-f1b12284b647
# ╟─bd886ee2-21a0-4f12-ba6b-6db00dffe507
# ╟─2fa1380e-f010-43b9-92d6-621360b4b2b7
# ╟─15c85cdd-8839-4664-866c-73e8f18155cd
# ╟─6b053d90-020e-4c6d-9488-f6456704a112
# ╟─54d99bab-4dd0-42d9-b6a6-5823dbd1ba97
# ╟─581f5aaa-2c67-4436-9d5d-41936a7f6712
# ╟─a67149d9-b9b7-4799-9d8c-e42b45aa33a0
# ╟─31294620-050a-45a6-9e0c-50613ee55596
# ╟─e131ff75-18dd-4262-a50a-f12d5cc8dbd0
# ╟─a7689b9d-b0a6-4a11-8924-b30afad83829
# ╟─d760f66a-4d25-495b-9471-2c9130065c1e
# ╟─2fd47be7-3763-49e0-a3f9-c043ce351d79
# ╟─dc436e60-b1f3-4d17-bb62-76adea32d633
# ╟─aefedada-315c-46d3-a443-8627a81f2287
# ╟─34260ef3-3583-408d-a7d7-cffa340ef52d
# ╟─3035ba16-0e9c-44bf-bdae-e61a1c763905
# ╟─895d8f0a-b325-4632-b7ca-337e1d04383d
# ╟─969497c9-8973-4abb-a798-08a348548c66
# ╟─3319e698-0905-4b5e-84bd-01885adb2a75
# ╟─a2b79da1-0279-4479-a50e-a15f076931b1
# ╟─7c139b46-a97f-4d2f-bfcb-afdcf9011db1
# ╟─e615c23a-9e39-4e98-815a-a21bf2eb8b7b
# ╟─5359d680-1780-4741-8038-8c33f940790a
# ╟─638caaa8-d394-4bb9-b22b-da90f9e0e911
# ╟─788972e1-6fcc-479b-9a9f-d2ca747820f8
# ╟─ebbcb72a-f6f8-449e-b1ab-47c9756ad50b
# ╟─09c4997f-22c5-41fd-945e-d82dea5d9489
# ╟─a0aa94e6-c173-4ed0-945a-9640739014e3
# ╟─02c17265-1f95-4858-aabe-ab6784f7cbac
# ╟─4968a4e8-345f-4b4f-b0de-ff221781f57b
# ╟─131f7542-62ca-4581-b745-9262e585bf47
# ╟─6aa3b45b-b2da-48db-9a6b-62eedd2dd698
# ╟─9c7460f8-b648-4ad4-99bc-ada7fa4afa84
# ╟─f14faaa3-e685-4955-8292-26d4bbc2aaf3
# ╟─60e7f3d0-248f-4fa0-bb02-1e1753fdee66
# ╟─aa5c658b-421f-4cbd-b7bd-5da6582ccff7
# ╟─65bc0f87-c726-4026-8a7f-bbdb70e0349e
