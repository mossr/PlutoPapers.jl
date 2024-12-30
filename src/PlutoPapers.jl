module PlutoPapers

using AbstractPlutoDingetjes
using Markdown
using Parameters
using PlutoTeachingTools
using Reexport
@reexport using LaTeXStrings
@reexport using Pluto
@reexport using PlutoUI
@reexport using Plots

import PlutoUI: @htl

include("refs.jl")
include("utils.jl")
include("documentclass.jl")
include("paper.jl")
include("macros.jl")
include("blocks.jl")
include("sidenotes.jl")
include("dark_mode.jl")
include("latex.jl")
include("Lipsum.jl")
using .Lipsum

export
    PlutoPaper,
    Author,
    Authors,
    title,
    @abstract,
    @section,
    @subsection,
    @subsubsection,
    @paragraph,
    @references,
    @star,
    @create,
    figure,
    table,
    code,
    toc,
    applyclass,
    setstyle,
    DocumentClass,
    NeurIPS,
    Tufte,
    sidenote,
    plot_default,
    get_aspect_ratio,
    set_aspect_ratio!,
    style,
    hide_cell,
    @hide_all_cells,
    show_cell,
    @show_all_cells,
    update_numbering,
    DarkModeIndicator,
    FootnotesRawNumbered,
    textsc,
    @latex_str,
    _latex,
    alg,
    alg2md,
    replace_cite_commands,
    replace_cref_commands,
    replace_Cref_commands,
    wrap_latex_environments,
    remove_latex_comments,
    split_camel_case,
    cite,
    cref,
    Cref,
    update_refs,
    apply_ref!,
    append_ref_update!,
    set_default_lipsum_markdown,
    lipsum_chars,
    lipsum_words,
    lipsum_sentences,
    lipsum


end # module PlutoPapers
