(deffunction gdc(?num1 ?num2)
    (if (neq ?num1 ?num2)
        then (if (> ?num1 ?num2)
            then (gdc (- ?num1 ?num2) ?num2)
            else (gdc ?num2 ?num1)
            )
        else (return ?num1)
    )
)