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

# ╔═╡ 81c5cd00-bcd3-11ef-0161-71e18722150b
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.develop(path="..")
	using Revise
	using PlutoPapers
	using Distributions
	using TikzPictures
	using PlutoUI
	using Plots
	using Statistics
	using JuMP
	using Ipopt

	Div = PlutoUI.ExperimentalLayout.Div

	md"`Pkg`"
end

# ╔═╡ 62b66b70-b203-49da-a947-0b806ab5a3ee
using Dates

# ╔═╡ 6df25687-a40f-47d1-abea-a35746fd879c
begin
	presentation = PlutoPaper(
		documentclass=Tufte(),
		title="Probability for Computer Scientists",
		authors=[
			# Author(name="Random Variables")
			# Author(name="Chris Piech")
			# Author(name="Robert Moss")
		]
	)
	Markdown.MD(
		applyclass(presentation.documentclass),
		md"""
		 $\newcommand{\bbE}{\mathbb{E}}$
		 $\DeclarePairedDelimiterXPP\bbE[1]{\mathbb{E}}{[}{]}{}{
			\renewcommand\given{  \nonscript\:
			  \delimsize\vert
			  \nonscript\:
			  \mathopen{}
			  \allowbreak}
			#1
			}$
		 $\DeclareMathOperator{\Var}{Var}$
		 $\DeclareMathOperator{\SD}{SD}$
		""",
		FootnotesRawNumbered(),
		toc(depth=4),
	)
end

# ╔═╡ 29e38973-7494-4302-8385-c559e1e9b39b
title(presentation)

# ╔═╡ 5d19f275-5f67-4553-ba7f-a409d6a0fdf8
@section "Random Variables"

# ╔═╡ 41d2218e-e9a4-43c8-87a9-ce2ce116c9aa
latex"""
A \textit{random variable} (RV) is a variable that probabilistically takes on different values. You can think of an RV as being like a variable in a programming language. They take on values, have types and have domains over which they are applicable. We can define events that occur if the random variable takes on values that satisfy a numerical test (e.g., does the variable equal $5$? is the variable less than $8$?). We often need to know the probabilities of such events.

As an example, let's say we flip three fair coins. We can define a random variable $Y$ to be the total number of ``heads'' on the three coins. We can ask about the probability of Y taking on different values using the following notation:
-  $P(Y = 0) = 1/8 \qquad (T, T, T)$
-  $P(Y = 1) = 3/8 \qquad (H, T, T),\, (T, H, T),\, (T, T, H)$
-  $P(Y = 2) = 3/8 \qquad (H, H, T),\, (H, T, H),\, (T, H, H)$
-  $P(Y = 3) = 1/8 \qquad (H, H, H)$
-  $P(Y \ge 4) = 0$
Even though we use the same notation for random variables and for events (both use capital letters), they are distinct concepts. An event is a situation, a random variable is an object. The situation in which a random variable takes on a particular value (or range of values) is an event. When possible, we % DIFF: I -> we
will try to use letters $E, F, G$ for events and $X, Y, Z$ for random variables. 

Using random variables is a convenient notation that assists in decomposing problems. There are many different types of random variables (indicator, binary, choice, Bernoulli, etc). The two main families of random variable types are discrete and continuous. For now we are going to develop intuition around discrete random variables.
"""

# ╔═╡ f345f4bd-268b-4679-b4b4-06e8017c99d3
@subsection "Probability Mass Function"

# ╔═╡ 7fb41433-3f0f-49c5-a7a0-80f0d53a08ff
Markdown.MD(latex"""
For a discrete random variable, the most important thing to know is the probability that the random variable will take on each of its possible values. The \textit{probability mass function} (PMF) of a random variable is a function that maps possible outcomes of a random variable to the corresponding probabilities. Because it is a function, we can plot PMF graphs where the $x$-axis contains the values that the random variable can take on and the $y$-axis contains the probability of the random variable taking on said value.
""",
# [^probability_mass]
# sidenote(md"[^probability_mass]: $(pmass)")
)

# ╔═╡ d876c6e0-bb87-43e1-bbb6-a8805058cda6
latex"""
There are many ways that probability mass functions can be specified. We can draw a graph. We can build a table (or for you CS folks, a \texttt{map}/\texttt{HashMap}/\texttt{dict}) that lists out all the probabilities for all possible events. Or we could write out a mathematical expression.

For example, consider the random variable X which is the sum of two dice rolls. The probability mass function can be defined by the graph on the right of \cref{fig:pmf_die}. It can also be defined using the equation:

$$p_X(x) = P(X=x) = \begin{cases}
	\frac{x-1}{36}  & \text{if } x \in \mathbb{Z},\, 1 \le x \le 7\\
	\frac{13-x}{36} & \text{if } x \in \mathbb{Z},\, 8 \le x \le 12\\
	0 & \text{otherwise} % DIFF: "else"
\end{cases}$$

The probability mass function, $p_X(x)$, defines the probability of $X$ taking on the value $x$. The new notation $p_X(x)$ is simply different notation for writing $P(X = x)$. Using this new notation makes it more apparent that we are specifying a function. Try a few values of $x$, and compare the value of $p_X(x)$ to the graph in \cref{fig:mass_sum}.
They should be the same.
"""

# ╔═╡ 0f9aaab9-d3f6-42bd-a1e6-9a847dd7e99d
md"Number of sides to the die: $(@bind 🎲 Slider([4, 6, 8, 10, 20], default=6, show_value=true))"

# ╔═╡ 2ef91e37-b999-4f7a-9a9d-567191477b07
@subsection "Expectation"

# ╔═╡ dc4615cf-07fb-486a-84f7-cc4d0c1a74bc
latex"""
A useful piece of information about a random variable is the average value of the random variable over many repetitions of the experiment it represents. This average is called the \textit{expectation}. The expectation of a discrete random variable X is defined as:
\begin{equation} % DIFF: old way = xP(x)
	\bbE{X} = \sum_{x \in X} x \cdot p_X(x),\, \text{ where } p_X(x) > 0 % DIFF: \bbE and \limits change (was x \colon P(x)>0)
\end{equation}
% TODO: Sampling?
It goes by many other names: \textit{mean}, \textit{expected value}, \textit{weighted average}, \textit{center of mass}, and \textit{first moment}. % DIFF: "1st" "and"
"""

# ╔═╡ cbb74d0e-bd56-4a0e-868e-40c3b22357c4
@subsection "Properties of Expectation"

# ╔═╡ 8f38cfa2-4b88-4e64-80eb-bc01957cb1c4
Markdown.MD(latex"""
Expectations preserve \textit{linearity}.[^expectation] Mathematically, this means that:

\begin{equation}
	\bbE{aX + bY + c} = a\bbE{X} + b\bbE{Y} + c
\end{equation}
So if you have an expectation of a sum of quantities, this is equal to the sum of the expectations of those quantities. We will return to the implications of this very useful fact later in the course.

One can also calculate the expected value of a function $g(X)$ of a random variable $X$ when one knows the probability distribution of $X$ but one does not explicitly know the distribution of $g(X)$:
\begin{equation}
	\bbE{g(X)} = \sum_x g(x) \cdot p_X(x)
\end{equation}
This identity has the humorous name of ``the Law of the Unconscious Statistician'' (LOTUS), for the fact that even statisticians are known, perhaps unfairly, to ignore the difference between this identity and the basic definition of expectation (the basic definition doesn't have a function $g$).

We can use this to compute, for example, the expectation of the square of a random variable (called the \textit{second moment} or \textit{second central moment}):
\begin{align*}
	\bbE{X^2} &= \bbE{g(X)} \tag{where $g(X) = X^2$}\\
	                &= \sum_x g(x) \cdot p_X(x) \tag{by LOTUS}\\
	                &= \sum_x x^2 \cdot p_X(x) \tag{definition of $g$}
\end{align*}
""",
sidenote(md"[^expectation]: For a review of _linear algebra_, see the textbook for [Stanford's Math 51](http://web.stanford.edu/class/math51/stanford/math51book.pdf).")
)

# ╔═╡ bb0408ee-53b1-477a-bb23-edfd9c9143e7
@subsection "Variance"

# ╔═╡ 414850cf-5c9f-453f-b982-3b6bd9845b32
Markdown.MD(latex"""
Expectation is a useful statistic, but it does not give a detailed view of the probability mass function. Consider the 4 distributions in \cref{fig:variance} (PMFs). All four have the same expected value $\bbE{X} = 3$ % DIFF: removed commas
but the ``spread'' in the distributions is quite different. \textit{Variance} is a formal quantification of ``spread''. There is more than one way to quantify spread; variance uses the average square distance from the mean.

The variance of a discrete random variable $X$ with expected value $\mu$ is defined:[^variance]""",
sidenote(md"[^variance]: _Variance_ has squared units relative to $X$."; v_offset=105),
latex"""
\begin{align}
	\Var(X) &= \bbE{(X - \bbE{X})^2}\\
			&= \bbE{(X - \mu)^2}\nonumber
\end{align}
When computing the variance, we often use a different form of the same equation:
""",
sidenote(latex"""\begin{align*}
	\qquad\Var(X) &= \bbE{(X - \bbE{X})^2} \\
	        &= \bbE{(X - \mu)^2} \qquad\qquad\; (\text{Let } \mu=\bbE{X}) \\ % DIFF: swapped order % TODO: didn't worK: \hskip \marginparwidth minus \marginparwidth
	        &= \sum_x (x - \mu)^2p(x)\\
	        &= \sum_x (x^2 - 2 \mu x + \mu^2)p(x)\\
	        &= \sum_x x^2p(x) - 2 \mu\sum_x xp(x) + \mu^2 \sum_x p(x)\\
	        &= \bbE{X^2} - 2\mu\bbE{X} + \mu^2 \cdot 1\\
	        &= \bbE{X^2} - 2\mu^2 + \mu^2\\
	        &= \bbE{X^2} - \mu^2\\
	        &= \bbE{X^2} - \bbE{X}^2 % DIFF: removed parens
\end{align*}
"""; v_offset=160),
latex"""
\begin{equation}
	\Var(X) = \bbE{X^2} - \bbE{X}^2 \tag{Property 1}
\end{equation}

A useful identity for variance, making it \textit{non-linear}, is that: % DIFF: "non-linear"
\begin{equation}
	\Var(aX + b) = a^2 \Var(X) \tag{Property 2}
\end{equation}
Adding a constant doesn't change the ``spread''; multiplying by one does.

To stay in the units of $X$, the \textit{standard deviation} is the square root of variance:
\begin{equation}
	\SD(X) = \sigma = \sqrt{\Var(X)} % DIFF: \sigma
\end{equation}
Intuitively, standard deviation is a kind of average distance of a sample to the mean.[^rms] Variance is the square of this average distance.""",
sidenote(latex"[^rms]: Specifically, it is a \textit{root-mean-square} (RMS) average."; v_offset=472)
)

# ╔═╡ 52783341-3ea5-4f07-9971-c608eee7d4c4
md" $\operatorname{Var}(X) \approx$ $(@bind σ² Slider(0.3:0.1:2, default=1, show_value=true))"

# ╔═╡ 8bbeccda-0fbc-4732-9ca5-7541bf3bea40
latex"""
\textit{Expected value} of random variable \texttt{X} with probabilities \texttt{P}, written in Julia. The symbol \texttt{𝔼} can be created by typing \texttt{\bbE} and hitting tab. The \texttt{.*} syntax broadcasts multiplication element-wise.
"""

# ╔═╡ 0758e4be-d73b-48df-8917-1ed5d1a3b0ac
𝔼(X, P) = sum(X .* P)

# ╔═╡ 21bea339-a4b0-40db-bf19-8821c4970528
latex"""
\textit{Variance} of random variable \texttt{X} using \textit{expectation} \texttt{𝔼}.
"""

# ╔═╡ 35f2c69c-1690-437b-a0d2-154da71640fa
Var(X, P) = 𝔼(X.^2, P) - 𝔼(X, P)^2

# ╔═╡ 0f3e893d-1850-491c-9540-5adc903a35e7
md"""
# Extras
"""

# ╔═╡ ff15f775-9cbd-4238-b7ad-22ab9fc61ee1
notebookpath() = replace(@__FILE__, r"#==#.*" => "")

# ╔═╡ 4693dfd5-984d-4927-9955-4866c3226086
function get_cell_ordering(notebook=notebookpath())
	local order_indicator = "# Cell order:"
	local celltype1 = "# ╟─"
	local celltype2 = "# ╠═"
	lines = readlines(notebook)
	cell_order_idx = findlast(line->line == order_indicator, lines)
	cell_order = filter(line->startswith(line, celltype1) || startswith(line, celltype2), lines[cell_order_idx+1:end])
	cell_order = replace.(cell_order, celltype1=>"")
	cell_order = replace.(cell_order, celltype2=>"")
	return Base.UUID.(cell_order)
end

# ╔═╡ f76411d3-7460-4922-9b8e-3b5f1547fbef
order = get_cell_ordering()

# ╔═╡ c3a8de01-670a-44e8-8d5e-d72d55d16338
function update_references()
	Markdown.MD(
		HTML(PlutoPapers.update_figure_numbering()),
		HTML(PlutoPapers.update_numbering()), # TODO: update_section_numbering
	)
end

# ╔═╡ b59932c5-67c6-4a94-bbdb-07a624e70bb9
"""
    watch_file_polling(file_path::String, interval::Seconds, on_change::Function)

Asynchronously monitors `file_path` for changes by polling every `interval` seconds.
When a change is detected, the `on_change` function is executed.

# Arguments
- `file_path::String`: Path to the file to monitor.
- `interval::Seconds`: Time interval between each poll.
- `on_change::Function`: Function to execute when a change is detected.
"""
function watch_file_polling(file_path::String, interval, on_change::Function)
    @async begin
        try
            # Get the initial modification time
            prev_mtime = stat(file_path).mtime

            @info("Started watching '$file_path' for changes every $interval seconds.")

            while true
                sleep(interval)  # Wait for the specified interval

                # Check if the file still exists
                if !isfile(file_path)
                    @info("File '$file_path' does not exist. Stopping watcher.")
                    break
                end

                # Get the current modification time
                current_mtime = stat(file_path).mtime

                # Compare with the previous modification time
                if current_mtime != prev_mtime
                    @info("Change detected in '$file_path' at $(now()).")
                    # on_change(file_path)
					break

                    # Update the previous modification time
                    prev_mtime = current_mtime
                end
            end
        catch e
            @info("An error occurred while watching the file: ", e)
        end
		@info on_change()
		on_change()
		watch_file_polling(file_path, interval, on_change) # recursive restart
    end
end

# ╔═╡ 75f4cae0-2b88-4704-8028-5b6e2b86e0b7
# watch_file_polling(notebookpath(), 0.5, update_references)

# ╔═╡ 5c56da77-a47f-4a13-98f7-5e9a28ed0ea8
function combine_html_md(contents::Vector; return_html=true)
    process(str) = str isa HTML ? str.content : html(str)
    html_string = join(map(process, contents))
    return return_html ? HTML(html_string) : html_string
end

# ╔═╡ 3a6013d1-1898-440e-bf2a-42bcd0ecdc7a
wrapdiv(html_or_md; kwargs...) = wrapdiv([html_or_md]; kwargs...)

# ╔═╡ 4fba837b-9d90-4bca-bfba-f0eda69eec10
function wrapdiv(html_or_md::Vector; options="", return_html=true)
    combine_html_md([HTML("<div $options>"), html_or_md, html"</div>"]; return_html)
end

# ╔═╡ 5673e669-4516-4cf9-8ca4-abcbefb59fe7
function example(html_or_md; options="", caption="", v_offset=30)
    ex = wrapdiv(html_or_md; options="class='example'$options")
	if isempty(caption)
		return ex
	else
		return Markdown.MD(ex, sidenote(caption; v_offset))
	end
end

# ╔═╡ 4e6c06a6-5475-47c9-951d-100fb772c1ea
example(latex"""
The random variable X represents the outcome of one roll of a six-sided die. What is $\bbE{X}$? This is the same as asking for the average value of a die roll.

$$\bbE{X} = 1(1/6) + 2(1/6) + 3(1/6) + 4(1/6) + 5(1/6) + 6(1/6) = 7/2 = 3.5$$
"""; caption=md"_Expected value_ of a size-sided die roll.")

# ╔═╡ 133450a4-193d-415c-b47e-6e549e549843
example(latex"""
A school has $3$ classes with $5$, $10$, and $150$ students. Each student is only in one of the three classes. If we randomly choose a class with equal probability and let $X$ be the the size of the chosen class:
\begin{align*}
	\bbE{X} &= 5(1/3) + 10(1/3) + 150(1/3)\\
		 &= 165/3 = 55
\end{align*}
However, if instead we randomly choose a student with equal probability and let $Y$ be the the size of the class the student is in:
\begin{align*}
	\bbE{Y} &= 5(5/165) + 10(10/165) + 150(150/165)\\
				  &= 22635/165 \approx 137 
\end{align*}
"""; caption=latex"Class size \textit{expected value} based on the choice of the \textit{random variable}.")

# ╔═╡ 411ae421-3507-4455-8532-56e573f2ecd6
example(latex"""
Consider a game played with a fair coin which comes up heads with $p = 0.5$. Let n = the number of coin flips before the first tails. In this game you win \$ $\!\!2^n$. How many dollars do you expect to win? Let $X$ be a random variable which represents your winnings.
\begin{align*}
	\bbE{X} &= \left( \frac{1}{2} \right)^1 2^0 + \left(\frac{1}{2}\right)^2 2^1 + \left(\frac{1}{2}\right)^3 2^2 + \cdots = \sum_{i=0}^\infty \left(\frac{1}{2}\right)^{i+1} 2^i\\ % DIFF: one less term: \left(\frac{1}{2}\right)^4 2^3 + 
				  &= \sum_{i=0}^\infty \frac{1}{2} = \infty
\end{align*}
"""; caption=latex"\textit{Expected value} game resulting in an infinite money paradox.")

# ╔═╡ 0dac47c8-5033-4916-88c3-5bec504066da
example(latex"""
Let $X$ be the value on one roll of a 6-sided die. % Recall that $E[X] = 7/2$ % DIFF: "recall" wording/placement.
What is $\Var(X)$?
% Let $X$ be the value of one 6-sided die roll (recall, $E[X] = 7/2$). What is $\Var(X)$?

\textbf{\textit{Solution:}}$\quad$ First, we can calculate $\bbE{X^2}$:
\begin{equation}
\bbE{X^2} = (1^2) \frac{1}{6} + (2^2) \frac{1}{6} + (3^2) \frac{1}{6} + (4^2) \frac{1}{6} + (5^2) \frac{1}{6} + (6^2) \frac{1}{6} = \frac{91}{6}
\end{equation}
Recall that $\bbE{X} = 7/2$, and we can use the expectation formula for variance:
\begin{align*}
	\Var(X) &= \bbE{X^2} - (\bbE{X})^2
			= \frac{91}{6} - \left(\frac{7}{2}\right)^2 = \frac{35}{12}	
\end{align*}"""; caption=latex"\textit{Variance} calculation of a single 6-sided die roll.")

# ╔═╡ 0215bcc5-0355-4dd7-a7a3-69014a09efa7
let
	X = 1:6
	P_str = "fill(1//6, 6)"
	P = eval(Meta.parse(P_str))

	example(Markdown.MD(
		latex"""
		Using the \texttt{𝔼} function and the \texttt{Var} function, we can recompute the answer to the above example. % \cref{eg:variance}.
		""",
		Markdown.parse("""
		```julia-repl
		julia> X = $X
		julia> P = $P_str
		julia> 𝔼(X, P)
		$(𝔼(X, P))
		julia> Var(X, P)
		$(Var(X, P))
		```
		""")
	); caption=latex"\textit{Expected value} and \textit{variance} functions in Julia; recomputing the previous example.
		Note the use of \texttt{//} to indicate a \texttt{Rational} type.")
end

# ╔═╡ 2419bf10-9678-45db-b495-8cb6287beb49
html"""
<style>
	.example {
		background-color: #f2f2f2;
		padding-top: 10px;
		padding-bottom: 10px;
		padding-left: 25px;
		padding-right: 25px;
		margin-top: 30px;
		margin-bottom: 30px;
		border-top: 1px solid var(--cursor-color);
		border-bottom: 1px solid var(--cursor-color);
	}

	@media (prefers-color-scheme: dark) {
		.example {
			background-color: #43423E;
			padding-top: 10px;
			padding-bottom: 10px;
			padding-left: 20px;
			padding-right: 20px;
			margin: 30px;
			border-top: 1px solid var(--cursor-color);
			border-bottom: 1px solid var(--cursor-color);
		}
	}
</style>"""

# ╔═╡ c7b1a302-87f9-4a3f-b3d0-f238175f4525
divcenter = Dict("display"=>"flex", "justify-content"=>"center")

# ╔═╡ 860d10a9-c85e-45f2-864a-50f0db0d78a6
Markdown.MD(
	# md"$(@hide_all_cells)",
	md"`@hide_all_cells`"
)

# ╔═╡ d5e13c72-4993-437d-a6b4-e5f90fe3fa5d
begin
	preamble = raw"""
	\usepackage{pgfplots}
	\usepackage{xcolor}
	\definecolor{pastelMagenta}{HTML}{FF48CF}
	\definecolor{pastelPurple}{HTML}{8770FE}
	\definecolor{pastelBlue}{HTML}{1BA1EA}
	\definecolor{pastelSeaGreen}{HTML}{14B57F}
	\definecolor{pastelGreen}{HTML}{3EAA0D}
	\definecolor{pastelOrange}{HTML}{C38D09}
	\definecolor{pastelRed}{HTML}{F5615C}
	"""
	md"`preamble`"
end

# ╔═╡ e11f1c05-9322-4731-8fe7-d54af18db645
# pmass = TikzPicture(raw"""
# \begin{axis}[ybar, axis on top=true, width=10cm, height=8cm, xlabel = {$x$}, ylabel = {$P(X=x)$}, ylabel style={rotate=-90}, ymin=0, ymax=1/5, xtick={1,2,...,6}, ytick={0, 1/6}, yticklabels={$0$, $1/6$}, yticklabel pos=right, every axis y label/.style={at={(ticklabel* cs:1.05)}, anchor=south}]
# 	\addplot+[pastelBlue] coordinates {(1,1/6) (2,1/6) (3,1/6) (4,1/6) (5,1/6) (6,1/6)};
# \end{axis}
# """; preamble)

# ╔═╡ fa82b60d-f29a-4255-b285-8d1437c940c1
Markdown.MD(
	md"$(@bind dark_mode PlutoPapers.DarkModeIndicator())",
	md"`DarkModeIndicator`"
)

# ╔═╡ fe39e72f-e51a-46b3-9988-b2f754c5cf69
begin
	plot_trigger = true
	plot_default(; dark_mode)
end

# ╔═╡ 554f4dce-698f-4265-aaa2-bfcded2668c6
figure(let
	plot_trigger

	die = DiscreteUniform(1, 6)
	bar(1:6, d->pdf(die, d);
		size=(400,300),
		xlabel="\$x\$",
		ylabel="\$P(X = x)\$",
		yticks=([1/6], ["1/6"]))
	# set_aspect_ratio!()
	ylims!(0, pdf(die, 1)*1.1)
end;
caption=md"The _probability mass function_ of a single 6-sided die roll.",
label="fig:pmf_die")

# ╔═╡ d316477d-ae92-4753-85f4-8a1702bd490d
figure(let
	plot_trigger

	function two_dice_pmf(num_sides)
		die1 = DiscreteUniform(1,num_sides)
		die2 = DiscreteUniform(1,num_sides)
		S = sum(support.([die1, die2]))
		pmf = Dict(x=>0.0 for x in first(S):last(S))
		for d1 in support(die1)
			for d2 in support(die2)
				pmf[d1 + d2] += pdf(die1, d1) * pdf(die2, d2)
			end
		end
		return pmf
	end

	pmf = two_dice_pmf(🎲)
	X = sort(collect(keys(pmf)))
	step = max(1, 🎲 ÷ 10)
	
	bar(X, s->pmf[s];
		size=(500,300),
		ygrid=true,
		xlabel="\$x\$",
		ylabel="""
		\$P(X = x)\$
		""",
		xticks=first(X):step:last(X),
		yticks=([i/🎲^2 for i in 1:step:🎲], ["$i/$(Int(🎲^2))" for i in 1:step:🎲]))

	ylims!(0, ylims()[2]*1.1)

end; caption=md"The _probability mass function_ of the sum of two $(🎲)-sided dice rolls.", label="fig:mass_sum")

# ╔═╡ 50803757-e545-4bfd-af23-efbd5ef3064a
figure(let
	plot_trigger

	function create_distribution(desired_variance, support, desired_mean=3)
	    n = length(support)

		# Find the index of the mean in the support
	    center = findfirst(x -> x == desired_mean, support)
	    if center === nothing
	        error("Desired mean must be in the support!")
	    end
	
	    # Create optimization model
	    model = Model(Ipopt.Optimizer)
		set_silent(model)  # Suppresses all output
	    @variable(model, p[1:n] >= 0)  # Probabilities must be non-negative
	    @variable(model, k >= 0)       # Exponential scaling factor for PMF symmetry
	
	    # Symmetric exponential relationship: outward from the mean
	    for i in 1:(center-1)
	        @constraint(model, p[i] == k^(center - i) * p[center])
	    end
	    for i in (center+1):n
	        @constraint(model, p[i] == k^(i - center) * p[center])
	    end
	
	    # Probabilities must sum to 1
	    @constraint(model, sum(p) == 1)
	
	    # Variance calculation
	    @expression(model, μ, sum(p[i] * support[i] for i in 1:n))  # Mean
	    @constraint(model, μ == desired_mean)  # Mean must equal the desired value
	    @expression(model, σ², sum(p[i] * (support[i]-μ)^2 for i in 1:n))  # Variance
	
	    # Objective: Minimize the difference between actual and desired variance
	    @objective(model, Min, (σ² - desired_variance)^2)
	
	    # Solve the optimization problem
	    optimize!(model)
	
	    # Extract probabilities
	    probs = value.(p)
	    return Categorical(probs)
	end

	X = 1:5
	d = create_distribution(σ², X)
	bar(X, x->pdf(d, x);
		size=(400,300),
		xlabel="\$x\$",
		ylabel="\$P(X = x)\$",
		yticks=0:0.2:0.8,
		ylims=(0, 0.8),
		title="\$\\mathrm{Var}(X) \\approx $(round(var(d); sigdigits=2))\$")
	# ylims!(0, ylims()[2]*1.1)
end;
caption=latex"Different \textit{variance} in \textit{probability mass functions}, each with expected value of ${\bbE{X}{=}3}$.",
label="fig:variance")

# ╔═╡ Cell order:
# ╟─6df25687-a40f-47d1-abea-a35746fd879c
# ╟─29e38973-7494-4302-8385-c559e1e9b39b
# ╟─5d19f275-5f67-4553-ba7f-a409d6a0fdf8
# ╟─41d2218e-e9a4-43c8-87a9-ce2ce116c9aa
# ╟─f345f4bd-268b-4679-b4b4-06e8017c99d3
# ╟─7fb41433-3f0f-49c5-a7a0-80f0d53a08ff
# ╟─554f4dce-698f-4265-aaa2-bfcded2668c6
# ╟─d876c6e0-bb87-43e1-bbb6-a8805058cda6
# ╟─d316477d-ae92-4753-85f4-8a1702bd490d
# ╟─0f9aaab9-d3f6-42bd-a1e6-9a847dd7e99d
# ╟─2ef91e37-b999-4f7a-9a9d-567191477b07
# ╟─dc4615cf-07fb-486a-84f7-cc4d0c1a74bc
# ╟─4e6c06a6-5475-47c9-951d-100fb772c1ea
# ╟─cbb74d0e-bd56-4a0e-868e-40c3b22357c4
# ╟─8f38cfa2-4b88-4e64-80eb-bc01957cb1c4
# ╟─133450a4-193d-415c-b47e-6e549e549843
# ╟─411ae421-3507-4455-8532-56e573f2ecd6
# ╟─bb0408ee-53b1-477a-bb23-edfd9c9143e7
# ╟─414850cf-5c9f-453f-b982-3b6bd9845b32
# ╟─50803757-e545-4bfd-af23-efbd5ef3064a
# ╟─52783341-3ea5-4f07-9971-c608eee7d4c4
# ╟─0dac47c8-5033-4916-88c3-5bec504066da
# ╟─8bbeccda-0fbc-4732-9ca5-7541bf3bea40
# ╠═0758e4be-d73b-48df-8917-1ed5d1a3b0ac
# ╟─21bea339-a4b0-40db-bf19-8821c4970528
# ╠═35f2c69c-1690-437b-a0d2-154da71640fa
# ╟─0215bcc5-0355-4dd7-a7a3-69014a09efa7
# ╟─0f3e893d-1850-491c-9540-5adc903a35e7
# ╟─ff15f775-9cbd-4238-b7ad-22ab9fc61ee1
# ╟─4693dfd5-984d-4927-9955-4866c3226086
# ╟─f76411d3-7460-4922-9b8e-3b5f1547fbef
# ╟─62b66b70-b203-49da-a947-0b806ab5a3ee
# ╟─c3a8de01-670a-44e8-8d5e-d72d55d16338
# ╟─b59932c5-67c6-4a94-bbdb-07a624e70bb9
# ╟─75f4cae0-2b88-4704-8028-5b6e2b86e0b7
# ╟─5673e669-4516-4cf9-8ca4-abcbefb59fe7
# ╟─5c56da77-a47f-4a13-98f7-5e9a28ed0ea8
# ╟─3a6013d1-1898-440e-bf2a-42bcd0ecdc7a
# ╟─4fba837b-9d90-4bca-bfba-f0eda69eec10
# ╟─2419bf10-9678-45db-b495-8cb6287beb49
# ╟─81c5cd00-bcd3-11ef-0161-71e18722150b
# ╟─c7b1a302-87f9-4a3f-b3d0-f238175f4525
# ╟─860d10a9-c85e-45f2-864a-50f0db0d78a6
# ╟─d5e13c72-4993-437d-a6b4-e5f90fe3fa5d
# ╟─e11f1c05-9322-4731-8fe7-d54af18db645
# ╟─fa82b60d-f29a-4255-b285-8d1437c940c1
# ╟─fe39e72f-e51a-46b3-9988-b2f754c5cf69
