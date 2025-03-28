(deftemplate probability
    (slot name)
    (multislot conditions+)     ;;parent nodes that are true
    (multislot conditions-)     ;parent nodes that are false
    (slot probability)
)

;;final probability for query
(deftemplate final-probability
    (slot value)
)

;;graph node
(deftemplate node
    (slot name)
    (multislot parents)
)

;joint probability
(deftemplate joint-probability
    (slot probability)
)

;;template for user-provided failure causes
(deftemplate cause
    (slot cause)
)

;;deftemplate for user-provided failure symptoms
(deftemplate symptoms
    (multislot symptoms)
)

(deffacts init-probabilities
    (probability (name "CPU_Alta") (conditions+) (conditions-) (probability 0.3))
    (probability (name "RAM_Error") (conditions+) (conditions-) (probability 0.15))
    (probability (name "Disco_Error") (conditions+) (conditions-) (probability 0.1))
    (probability (name "Temp_Alta") (conditions+ "CPU_Alta") (conditions-) (probability 0.8))
    (probability (name "Temp_Alta") (conditions+ ) (conditions- "CPU_Alta") (probability 0.1))
    (probability (name "Reinicio") (conditions+ "RAM_Error" "Temp_Alta") (conditions- ) (probability 0.9))
    (probability (name "Reinicio") (conditions+ "RAM_Error" ) (conditions- "Temp_Alta") (probability 0.75))
    (probability (name "Reinicio") (conditions+  "Temp_Alta") (conditions- "RAM_Error")(probability 0.7))
    (probability (name "Reinicio") (conditions+ ) (conditions- "RAM_Error" "Temp_Alta") (probability 0.1))
    (probability (name "SO_Inestable") (conditions+ "CPU_Alta" "Disco_Error") (conditions- ) (probability 0.95))
    (probability (name "SO_Inestable") (conditions+ "CPU_Alta" ) (conditions- "Disco_Error") (probability 0.9))
    (probability (name "SO_Inestable") (conditions+  "Disco_Error") (conditions- "CPU_Alta")(probability 0.6))
    (probability (name "SO_Inestable") (conditions+ ) (conditions- "CPU_Alta" "Disco_Error") (probability 0.2))
    (probability (name "Caida_Servidor") (conditions+ "Reinicio" "SO_Inestable" "Temp_Alta") (conditions- ) (probability 0.98))
    (probability (name "Caida_Servidor") (conditions+ "Reinicio" "SO_Inestable" ) (conditions- "Temp_Alta") (probability 0.95))
    (probability (name "Caida_Servidor") (conditions+ "Reinicio" "Temp_Alta") (conditions- "SO_Inestable") (probability 0.85))
    (probability (name "Caida_Servidor") (conditions+ "Reinicio") (conditions- "SO_Inestable" "Temp_Alta") (probability 0.75))
    (probability (name "Caida_Servidor") (conditions+ "SO_Inestable" "Temp_Alta") (conditions- "Reinicio") (probability 0.7))
    (probability (name "Caida_Servidor") (conditions+ "SO_Inestable" ) (conditions- "Reinicio" "Temp_Alta") (probability 0.5))
    (probability (name "Caida_Servidor") (conditions+  "Temp_Alta") (conditions- "Reinicio" "SO_Inestable") (probability 0.3))
    (probability (name "Caida_Servidor") (conditions+ ) (conditions- "Reinicio" "SO_Inestable" "Temp_Alta") (probability 0.01))
    (joint-probability (probability (* 0.98 0.95 0.9 0.8 0.15 0.3)))
)

(defrule init-graph
    =>
    (assert (node (name "CPU_Alta") (parents)))
    (assert (node (name "Disco_Error") (parents)))
    (assert (node (name "RAM_Error") (parents)))
    (assert (node (name "SO_Inestable") (parents "CPU_Alta" "Disco_Error")))
    (assert (node (name "Temp_Alta") (parents "CPU_Alta")))
    (assert (node (name "Reinicio") (parents "RAM_Error")))
    (assert (node (name "Caida_Servidor") (parents "Reinicio" "SO_Inestable" "Temp_Alta")))
    (assert (final-probability (value 0)))
    (assert (ready))
)

(deffunction read-input(?prompt)
    (printout t ?prompt crlf)
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

;;it looks stupid but i dont know how to handle input smarter way
(defrule read-input
    (ready)
    =>
    (bind ?input1 (read-input "Please provide cause"))
    (bind ?input2 (read-input "Please provide symptoms"))
    (assert (cause (cause ?input1)))
    (bind ?symptoms (split ?input2))
    (bind ?list (create$))
    (foreach ?symptom ?symptoms
        (bind ?list (create$ ?list ?symptom))
    )    
    (assert (symptoms (symptoms ?list)))
)

(defrule calculate-probability-1    ;;when all substrates are know - just read from table
    (ready)
    ?probability <- (probability (name ?n) (conditions+ $?condp) (conditions- $?condn) (probability ?p))
    ?symptoms <- (symptoms(symptoms $?s))
    ?node <- (node (name ?n) (parents $?condp))
    (test (and 
        (subsetp ?condp ?s)  ; All elements of ?mf1 exist in ?mf2
        (subsetp ?s ?condp)  ; All elements of ?mf2 exist in ?mf1
        (eq (length$ ?condp) (length$ ?s))  ; Ensure same number of elements
      ))
    =>
    (printout t "Probability of happening is: " ?p crlf)
)

;;calculates partia probability for each node of query
;;P(A) = SUM(P(A|Xi)*P(Xi)) (sum for booolean values of Xi)

;;eg. P(C|R,T) = sum{S} P(C|R,T,S)*P(S)
    ;;P(S) = sum{CPU,D} P(S|CPU,D)*P(CPU,D)
(defrule calculate-probability-2    ;;if its a cause
    ?final-p <- (final-probability (value ?p1))
    ?probability <- (probability (name ?n) (conditions+ $?condp) (conditions- $?condn) (probability ?p))
    ?symptoms <- (symptoms(symptoms $?s))
    ?cause <- (cause (cause ?n))
    ?node <- (node (name ?n) (parents $?par))
    (test (neq ?condp ?par))
    =>
    (printout t ?p crlf)
    (bind ?prob (calculate-recursive-call ?p ?n ?s))
)

;;eg. P(C|R,T) = sum{S} P(C|R,T,S)*P(S)
    ;;P(S) = sum{CPU,D} P(S|CPU,D)*P(CPU,D)
(deffunction calculate-recursive-call (?p ?n ?s)    ;;probability, node, symptoms
    (bind ?probability 0)
    (if (neq (length$ ?n:parents) 0) then ;;if node has parents, need to check which of them are included in symptoms
        ;;need to loop through all facts that are not symptoms and are parents of current node
        (foreach ?f (find-all-facts (?f probability)) (and (member$ ?f:name ?n:parents) (not (member$ ?f:name ?s:symptoms)))
            (if (and (member$ ?f:name ?n:parents) 
            (not (member$ ?f:name ?s:symptoms))) then
            ;;find corresponding node fact
                (foreach ?n2 (find-all-facts (?n2 node)) (eq (?f:name ?n2:name)))
                    (bind ?probability (+ (* (calculate-recursive-call ?f ?n2 ?s) ?f:probability) ?partial-sum))
            )
        )
    (return ?probability)           
    else
        (return ?p:probability)
    )   
)