# Taken and modified from https://github.com/JuliaPluto/PlutoTeachingTools.jl/blob/main/src/footnotes.jl
# Credit: unnamedunknownusername, Adrian Hill (adrhill), and Eric Ford (eford)

const sidenote = aside # alias from PlutoTeachingTools

function FootnotesInlineNumbered()
    html"""
    <script id="footnotes">
    const addNumbersToInlineFootnotes = () => {


    const inlinefootnotesNodes=document.querySelectorAll("a.footnote")
    const bottomfootnoteNodes=document.getElementsByClassName("footnote-title")


    const botttomFootnoteTextList=Array.from(bottomfootnoteNodes).map(x=>x.innerText);


    //get the inline footers inner text so that we can match up with the 
    const inlineFootnoteTextList=Array.from(inlinefootnotesNodes)
    .map(x=>x.innerText)


    //add square brackets to match the inline footnotes
    const botttomFootnoteTextListWithBrackets=botttomFootnoteTextList.map(x=>"["+x+"]");


    //find the number which we want to display inline
    var inlineFootnoteTextListWithNumbers = inlineFootnoteTextList
    .map((x,index)=>{

    const indexOfBottomFootnote = botttomFootnoteTextListWithBrackets.indexOf(x)
    const indexOfBottomFootnotePlus1 = indexOfBottomFootnote+1
    const element = inlinefootnotesNodes[index]

    //modify the element before part depending on if we find a match
    if (indexOfBottomFootnote<0) 
    {//if we don't find a match display an error
    	element.setAttribute("data-before","["+"ERROR! no matching reference"+"]")
    }
    else 
    {//if we do add the number and make the label disapear by sizing it to 0px
		// NOTE: Changed this so the style is without [square brackets]
    	element.setAttribute("data-before", indexOfBottomFootnotePlus1.toString())
    }

    return indexOfBottomFootnotePlus1

    })

    }//end of function addNumbersToInlineFootnotes


    //run everytime "something" is done so that it updates dynamically/reactively
    //2022/10/28
    //all of the below was taken from Table of Contents in PlutoUI 
    const invalidated = { current: false }
    const updateCallback = () => {
    	if (!invalidated.current) {
    		addNumbersToInlineFootnotes()
    	}
    }
    updateCallback()
    setTimeout(updateCallback, 100)
    setTimeout(updateCallback, 1000)
    setTimeout(updateCallback, 5000)
    const notebook = document.querySelector("pluto-notebook")
    // We have a mutationobserver for each cell:
    const mut_observers = {
    	current: [],
    }
    const createCellObservers = () => {
    	mut_observers.current.forEach((o) => o.disconnect())
    	mut_observers.current = Array.from(notebook.querySelectorAll("pluto-cell")).map(el => {
    		const o = new MutationObserver(updateCallback)
    		o.observe(el, {attributeFilter: ["class"]})
    		return o
    	})
    }
    createCellObservers()

    // And one for the notebook's child list, which updates our cell observers:
    const notebookObserver = new MutationObserver(() => {
    	updateCallback()
    	createCellObservers()
    })
    notebookObserver.observe(notebook, {childList: true})

    // And finally, an observer for the document.body classList, to make sure that the fotnotz also works when it is loaded during notebook initialization
    const bodyClassObserver = new MutationObserver(updateCallback)
    bodyClassObserver.observe(document.body, {attributeFilter: ["class"]})
    </script>

    <style>
    a.footnote {
    	font-size: 0 !important;
    }
    a.footnote::before {
    	content: attr(data-before) ;
    	font-size: 10px;
    }
    </style>
    """
end

function FootnotesStandaloneNumbered()
    html"""
    <style> 
    pluto-notebook {
	    counter-reset:  footnote-title;
    }

	pluto-notebook .footnote {
		font-weight: unset !important;
		text-decoration: unset !important;
		vertical-align: super !important;
	}

    .footnote-title {
	    font-size: 0 !important;
		font-weight: unset !important;
		vertical-align: super !important;
    }

    .footnote-title::before {
	    counter-increment: footnote-title !important;
	    content: counter(footnote-title) !important;
	    font-size: 0.75rem !important;
    }
    </style>
    """
end

function FootnotesRawNumbered()
    PlutoTeachingTools.combine() do Child
        @htl("""
        $(Child(FootnotesInlineNumbered()))
        $(Child(FootnotesStandaloneNumbered()))
        """)
    end
end