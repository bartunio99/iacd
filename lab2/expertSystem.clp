(deftemplate symptom
    (multislot name)
)

(deftemplate sickness
    (slot name)
    (multislot symptoms)
    (multislot diagnosis)
)

(defrule init-sickness
    =>
    (assert (sickness (name gripe) (symptoms "fiebre" "tos" "dolor de garganta") (diagnosis "Es probable que tengas gripe. Descansa y mantente hidratado.")))
    (assert (sickness (name resfriado-comun) (symptoms "dolor de garganta" "congestion nasal"  "estornudos") (diagnosis "Es probable que tengas un resfriado común. Descansa y beber líquidos.")))
    (assert (sickness (name alergia) (symptoms "estornudos" "picazon de ojos" "congestion nasal") (diagnosis "Es probable que tengas una alergia. Considera tomar un antihistamínico.")))
    (assert (sickness (name amigdalitis) (symptoms "fiebre" "dolor de garganta" "dificultad para tragar") (diagnosis "Es probable que tengas amigdalitis. Consulta a un médico para un tratamiento adecuado.")))
    (assert (sickness (name bronquitis) (symptoms "tos" "flema" "dificultad para respirar") (diagnosis "Es probable que tengas bronquitis. Consulta a un médico para un tratamiento adecuado.")))
    (assert (sickness (name neumonia) (symptoms "fiebre" "tos" "dolor en el pecho") (diagnosis "Es probable que tengas neumonía. Consulta a un médico de inmediato.")))
    (assert (sickness (name gastroenteritis) (symptoms "nauseas" "vomitos" "diarrea") (diagnosis "Es probable que tengas gastroenteritis. Mantente hidratado y consulta a un médico si los síntomas persisten.")))
    (assert (sickness (name migrana) (symptoms "dolor de cabeza" "sensibilidad a la luz" "nauseas") (diagnosis "Es probable que tengas una migraña. Descansa en un lugar oscuro y tranquilo")))
    (assert (sickness (name diabetes) (symptoms "sed excesiva" "orina frecuente" "perdida de peso") (diagnosis "Es posible que tengas diabetes. Consulta a un médico para un diagnóstico y tratamiento adecuado")))
    (assert (sickness (name hipertension) (symptoms "dolor de cabeza" "mareos" "vision borrosa") (diagnosis "Es posible que tengas hipertensión. Consulta a un médico para un diagnóstico y tratamiento adecuado")))
    (assert (sickness (name artritis) (symptoms "dolor en las articulaciones" "rigidez" "hinchazon") (diagnosis "Es probable que tengas artritis. Consulta a un médico para un tratamiento adecuado")))
    (assert (sickness (name anemia) (symptoms "fatiga" "palidez" "dificultad para respirar") (diagnosis "Es posible que tengas anemia. Consulta a un médico para un diagnóstico y tratamiento adecuado")))
    (assert (sickness (name depresion) (symptoms "tristeza" "perdida de interes" "fatiga") (diagnosis "Es posible que tengas depresión. Consulta a un profesional de la salud mental para obtener ayuda.")))
    (assert (sickness (name ansiedad) (symptoms "nerviosismo" "inquietud" "dificultad para dormir") (diagnosis "Es posible que tengas ansiedad. Consulta a un profesional de la salud mental para obtener ayuda")))
    (assert (sickness (name hipotiroidismo) (symptoms "fatiga" "aumento de peso" "piel seca") (diagnosis "Es posible que tengas hipotiroidismo. Consulta a un médico para un diagnóstico y tratamiento adecuado.")))
    (assert (sicknesses-initialized))
)

(deffunction read-input()
    (printout t "Please provide your symptoms: " crlf)
    (return (readline))
) 

(deffunction explode-string (?input)
    (bind ?result (create$))  ;; Initialize an empty multifield
    (bind ?length (str-length ?input))  ;; Get the string length
    (bind ?index 1)  ;; Start at index 1

    (while (<= ?index ?length) do
        (bind ?char (sub-string ?index ?index ?input))  ;; Get one character
        (bind ?result (create$ ?result ?char))  ;; Add the character to the multifield
        (bind ?index (+ ?index 1))
    )  ;; Increment the index

    (return ?result)
)  ;; Return the result as a multifield

(deffunction split (?input)
    (bind ?result (create$))  ;; Initialize an empty multifield
    (bind ?temp "")           ;; Temporary storage for word
    (bind ?skip-first-space? TRUE)  ;; Flag to skip the first space

    (foreach ?char (explode-string ?input)  ;; Iterate over characters
        (if (and ?skip-first-space? (eq ?char " ")) then
            ;; Skip the first space
            (bind ?skip-first-space? FALSE)
        else
            (if (neq ?char ",") then
                (bind ?temp (str-cat ?temp ?char))  ;; Append character to temp
            else
                (if (neq ?temp "") then
                    (bind ?result (create$ ?result ?temp))  ;; Add temp to result
                    (bind ?temp "")
                    (bind ?skip-first-space? TRUE)
                )
            )  ;; Reset temp when a comma is found
        )
    )    
   ;; Add the last collected word (if any)
    (if (neq ?temp "") then
        (bind ?result (create$ ?result ?temp))
    )

    (return ?result) ;; Return the result as a multifield
)

(defrule read-input
    (sicknesses-initialized)
    =>
    (bind ?input (read-input))
    (bind ?symptoms (split ?input))
    (foreach ?symptom ?symptoms
        (assert (symptom (name ?symptom)))
    )
    (assert (ready))
)

(defrule find-sickness
    (ready)
    ?symptom <- (symptom (name ?n))
    =>
    (foreach ?sickness (find-all-facts ((?sickness sickness)) TRUE)
        (bind ?symptoms (fact-slot-value ?sickness symptoms))
        (bind ?symptom-found FALSE)
            (foreach ?s ?symptoms
                (if (eq ?s ?n) then
                    (bind ?symptom-found TRUE)
                )
            )

            (if (not ?symptom-found) then
                (retract ?sickness)  ;; Retract only if ?n was not found
            )
    )   
)

(defrule print-diagnosis
    (ready)
    =>
    (bind ?count 0)
    (bind ?diagnosis "")
    (foreach ?sickness (find-all-facts ((?sickness sickness)) TRUE)
        (bind ?count (+ ?count 1))
        (bind ?diagnosis (fact-slot-value ?sickness diagnosis))
    )

    (if (= ?count 1) then
        (printout t ?diagnosis crlf)
    else
        (printout t "no matching disease" crlf)
    )

)



