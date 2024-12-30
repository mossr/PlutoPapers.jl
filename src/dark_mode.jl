Bonds = AbstractPlutoDingetjes.Bonds

struct DarkModeIndicator
    default::Bool
end

DarkModeIndicator(; default::Bool=false) = DarkModeIndicator(default)

function Base.show(io::IO, ::MIME"text/html", link::DarkModeIndicator)
    print(io, """
        <span>
        <script>
            const span = currentScript.parentElement
            span.value = window.matchMedia('(prefers-color-scheme: dark)').matches
        </script>
        </span>
    """)
end

Base.get(checkbox::DarkModeIndicator) = checkbox.default
Bonds.initial_value(b::DarkModeIndicator) = b.default
Bonds.possible_values(b::DarkModeIndicator) = [false, true]
Bonds.validate_value(b::DarkModeIndicator, val) = val isa Bool
