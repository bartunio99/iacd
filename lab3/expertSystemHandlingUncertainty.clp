;;template for user-provided symptoms
(deftemplate symptom
    (slot name)
)

;;Define prior probabilities
(deftemplate prior-probability
    (slot name)
    (slot probability)
)

;;init facts
(deffacts init-prior
    (prior-probability (name "gripe") (probability 0.33))
    (prior-probability (name "resfriado comun") (probability 0.493))
    (prior-probability (name "alergia") (probability 0.2322))
    (prior-probability (name "amigdalitis") (probability 0.02))
    (prior-probability (name "bronquitis") (probability 0.0318))
    (prior-probability (name "neumonia") (probability 0.005))
)

;;Define conditional probabilities
(deftemplate conditional-probability
    (slot disease)
    (slot symptom)
    (slot probability)
)

;;Init symptom conditional probability table - gripe
(deffacts gripe-conditional
    (conditional-probability (disease "gripe") (symptom "fiebre") (probability 0.95))
    (conditional-probability (disease "gripe") (symptom "tos") (probability 0.82))
    (conditional-probability (disease "gripe") (symptom "dolor de garganta") (probability 0.68))
    (conditional-probability (disease "gripe") (symptom "congestion nasal") (probability 0.32))
    (conditional-probability (disease "gripe") (symptom "estornudos") (probability 0.42))
    (conditional-probability (disease "gripe") (symptom "picazon en los ojos") (probability 0.13))
    (conditional-probability (disease "gripe") (symptom "dificultad para tragar") (probability 0.05))
    (conditional-probability (disease "gripe") (symptom "flema") (probability 0.03))
    (conditional-probability (disease "gripe") (symptom "dificultad para respirar") (probability 0.16))
    (conditional-probability (disease "gripe") (symptom "dolor de pecho") (probability 0.04))
)

;;Init symptom conditional probability table - resfriado comun
(deffacts resfriado-comun-conditional
    (conditional-probability (disease "resfriado comun") (symptom "fiebre") (probability 0.34))
    (conditional-probability (disease "resfriado comun") (symptom "tos") (probability 0.19))
    (conditional-probability (disease "resfriado comun") (symptom "dolor de garganta") (probability 0.84))
    (conditional-probability (disease "resfriado comun") (symptom "congestion nasal") (probability 0.89))
    (conditional-probability (disease "resfriado comun") (symptom "estornudos") (probability 0.91))
    (conditional-probability (disease "resfriado comun") (symptom "picazon en los ojos") (probability 0.17))
    (conditional-probability (disease "resfriado comun") (symptom "dificultad para tragar") (probability 0.14))
    (conditional-probability (disease "resfriado comun") (symptom "flema") (probability 0.12))
    (conditional-probability (disease "resfriado comun") (symptom "dificultad para respirar") (probability 0.28))
    (conditional-probability (disease "resfriado comun") (symptom "dolor de pecho") (probability 0.15))
)

;;Init symptom conditional probability table - alergia
(deffacts alergia-conditional
    (conditional-probability (disease "alergia") (symptom "fiebre") (probability 0.15))
    (conditional-probability (disease "alergia") (symptom "tos") (probability 0.23))
    (conditional-probability (disease "alergia") (symptom "dolor de garganta") (probability 0.09))
    (conditional-probability (disease "alergia") (symptom "congestion nasal") (probability 0.79))
    (conditional-probability (disease "alergia") (symptom "estornudos") (probability 0.87))
    (conditional-probability (disease "alergia") (symptom "picazon en los ojos") (probability 0.77))
    (conditional-probability (disease "alergia") (symptom "dificultad para tragar") (probability 0.08))
    (conditional-probability (disease "alergia") (symptom "flema") (probability 0.12))
    (conditional-probability (disease "alergia") (symptom "dificultad para respirar") (probability 0.41))
    (conditional-probability (disease "alergia") (symptom "dolor de pecho") (probability 0.26))
)

;;Init symptom conditional probability table - amigdalitis
(deffacts amigdalitis-conditional
    (conditional-probability (disease "amigdalitis") (symptom "fiebre") (probability 0.91))
    (conditional-probability (disease "amigdalitis") (symptom "tos") (probability 0.2))
    (conditional-probability (disease "amigdalitis") (symptom "dolor de garganta") (probability 0.95))
    (conditional-probability (disease "amigdalitis") (symptom "congestion nasal") (probability 0.07))
    (conditional-probability (disease "amigdalitis") (symptom "estornudos") (probability 0.05))
    (conditional-probability (disease "amigdalitis") (symptom "picazon en los ojos") (probability 0.02))
    (conditional-probability (disease "amigdalitis") (symptom "dificultad para tragar") (probability 0.9))
    (conditional-probability (disease "amigdalitis") (symptom "flema") (probability 0.02))
    (conditional-probability (disease "amigdalitis") (symptom "dificultad para respirar") (probability 0.13))
    (conditional-probability (disease "amigdalitis") (symptom "dolor de pecho") (probability 0.03))
)

;;Init symptom conditional probability table - bronquitis
(deffacts bronquitis-conditional
    (conditional-probability (disease "bronquitis") (symptom "fiebre") (probability 0.42))
    (conditional-probability (disease "bronquitis") (symptom "tos") (probability 0.93))
    (conditional-probability (disease "bronquitis") (symptom "dolor de garganta") (probability 0.14))
    (conditional-probability (disease "bronquitis") (symptom "congestion nasal") (probability 0.35))
    (conditional-probability (disease "bronquitis") (symptom "estornudos") (probability 0.1))
    (conditional-probability (disease "bronquitis") (symptom "picazon en los ojos") (probability 0.08))
    (conditional-probability (disease "bronquitis") (symptom "dificultad para tragar") (probability 0.17))
    (conditional-probability (disease "bronquitis") (symptom "flema") (probability 0.85))
    (conditional-probability (disease "bronquitis") (symptom "dificultad para respirar") (probability 0.81))
    (conditional-probability (disease "bronquitis") (symptom "dolor de pecho") (probability 0.39))
)

;;Init symptom conditional probability table - neumonia
(deffacts neumonia-conditional
    (conditional-probability (disease "neumonia") (symptom "fiebre") (probability 0.93))
    (conditional-probability (disease "neumonia") (symptom "tos") (probability 0.91))
    (conditional-probability (disease "neumonia") (symptom "dolor de garganta") (probability 0.37))
    (conditional-probability (disease "neumonia") (symptom "congestion nasal") (probability 0.41))
    (conditional-probability (disease "neumonia") (symptom "estornudos") (probability 0.25))
    (conditional-probability (disease "neumonia") (symptom "picazon en los ojos") (probability 0.1))
    (conditional-probability (disease "neumonia") (symptom "dificultad para tragar") (probability 0.09))
    (conditional-probability (disease "neumonia") (symptom "flema") (probability 0.34))
    (conditional-probability (disease "neumonia") (symptom "dificultad para respirar") (probability 0.56))
    (conditional-probability (disease "neumonia") (symptom "dolor de pecho") (probability 0.78))
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
    =>
    (bind ?input (read-input))
    (bind ?symptoms (split ?input))
    (foreach ?symptom ?symptoms
        (assert (symptom (name ?symptom)))
    )
    (assert (ready))
)

