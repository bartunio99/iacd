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

;;template for user-provided failure causes
(deftemplate cause
    (slot cause)
)

;;deftemplate for user-provided failure symptoms
(deftemplate symptoms
    (multislot symptoms)
)

;;template for additional nodes
(deftemplate bonus-nodes
    (multislot nodes)
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
    (assert (bonus-nodes (nodes (create$))))
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

(defrule calculate-probability-1    ;;basic case, all of parents of cause node are present in query
    (ready)
    ?probability <- (probability (name ?n) (conditions+ $?condp) (conditions- $?condn) (probability ?p))
    ?symptoms <- (symptoms(symptoms $?s))
    ?cause <- (cause(cause ?n))
    ?node <- (node (name ?n) (parents $?condp))
    (test (and 
        (subsetp ?condp ?s)  ; All elements of ?mf1 exist in ?mf2
        (subsetp ?s ?condp)  ; All elements of ?mf2 exist in ?mf1
        (eq (length$ ?condp) (length$ ?s))  ; Ensure same number of elements
      ))
    =>
    (printout t "Probability of happening is: " ?p crlf)
)

;;add bonus nodes for cause node if needed
(defrule add-nodes-cause
    (ready)
    ?bonus <- (bonus-nodes (nodes $?x))
    ?probability <- (probability (name ?n) (conditions+ $?condp) (conditions- $?condn) (probability ?p))
    ?symptoms <- (symptoms(symptoms $?s))
    ?cause <- (cause(cause ?n))
    (test (and 
        (subsetp ?condn ?s)  ; All elements of ?mf1 exist in ?mf2
        (subsetp ?s ?condn)  ; All elements of ?mf2 exist in ?mf1
        (eq (length$ ?condn) (length$ ?s))  ; Ensure same number of elements
      ))
    =>
    (bind ?new-nodes $?x)

    ;; Only add new nodes if they aren't already in the list
    (foreach ?node $?condp
        (if (not (member$ ?node $?x)) then ; Check if the node is not already in the list
            (bind ?new-nodes (create$ $?new-nodes ?node))
        )
    )
    ;; If new nodes were added, update bonus-nodes
    (if (neq (length$ ?new-nodes) (length$ $?x))  ;; Check if nodes were added
        then
            (retract ?bonus)
            (assert (bonus-nodes (nodes $?new-nodes)))
    )    
)
(deffunction list-subtract (?list1 ?list2)
   (bind ?result (create$))  ; Initialize result as an empty multifield
   (foreach ?item ?list1
      (if (not (member$ ?item ?list2)) then
         (bind ?result (insert$ ?result (+ (length$ ?result) 1) ?item))  ; Insert at the correct index
      )
   )
   (return ?result))  ; Return the result


(deffunction calculate-probability-function (?c ?s ?l ?n)
    (bind ?sum 0)
    ;;all facts to loop through our sum P(A|B,C...)
    (foreach ?probability (find-all-facts ((?probability probability)) TRUE)
        (bind ?partial-sum 1)
        (bind ?conditions (fact-slot-value ?probability conditions+))
        (bind ?n-conditions (fact-slot-value ?probability conditions-))
        (bind ?p-name (fact-slot-value ?probability name))
        (if (eq ?n 0) then
            (bind ?s ?conditions)
        )

        (if (and (eq ?p-name ?c) (subsetp ?s ?conditions))then
            ;;multiply partial sum
            (bind ?p1 (fact-slot-value ?probability probability))
            (bind ?partial-sum (* ?partial-sum ?p1))
            (printout t "Main fact is: " ?c "  " ?p1 ". id: " ?probability crlf)
            (bind ?p2 0)
            (bind ?looped 0)
            
            ;;find P(x)s needed to further operations
            (foreach ?probability-2 (find-all-facts ((?probability-2 probability)) TRUE)
                (bind ?p-name2 (fact-slot-value ?probability-2 name))
                (bind ?conditions2 (fact-slot-value ?probability-2 conditions+))
                (bind ?n-conditions2 (fact-slot-value ?probability-2 conditions-))
                (if (member$ ?p-name2 ?l) then
                    (if (or (neq (length$ ?conditions2) 0) (neq (length$ ?n-conditions2) 0)) then
                        (if (eq ?p2 0) then
                            (bind ?l2 (create$ ?conditions2 ?n-conditions2))  ;;all conditions that are true
                            (bind ?s3 (list-subtract ?l2 ?n-conditions2 ))  ;;remove symptoms that are not in the query
                            (printout t "recursion!  " ?p-name2 " " ?conditions2 " " ?n-conditions2 "..." ?l2 crlf)
                            (bind ?p2 (calculate-probability-function ?p-name2 ?s ?s3 0))
                            (printout t ";-;  "  crlf)
                        )
                    else
                        (bind ?p2 (fact-slot-value ?probability-2 probability)))
                    (if (or (eq ?n 0) (and (eq ?n 1) (eq ?looped 0))) then
                        (if (member$ ?p-name2 ?conditions) then
                            (bind ?partial-sum (* ?partial-sum ?p2))
                            (printout t "Other fact is +: " ?p-name2 "  " ?p2 ", id: " ?probability-2 crlf)
                        else 
                            (bind ?partial-sum (* ?partial-sum (- 1 ?p2)))
                            (printout t "Other fact is -: " ?p-name2 "  " (- 1 ?p2) ", id: " ?probability-2 crlf)
                        )
                        (bind ?looped 1)
                    )
                )
            )
            (bind ?sum (+ ?sum ?partial-sum))           
        )
    )
    (return ?sum)
)

;P(A|B,D,C)= sum(D)(P(A|B=T,C=T,D)P(D))  (eg. if D not known)
;if D depends on other probabilities it also needs to be considered
(defrule calculate-probability
    ?ready <- (ready)
    ?cause <- (cause (cause ?c))
    ?bonus <- (bonus-nodes (nodes $?b))
    ?symptoms <- (symptoms (symptoms $?s1))
    ?probability <- (probability (name ?c) (conditions+ $?s2) (conditions- $?n) (probability ?p))    ;;the base probability, we will through ?n symptoms
    (test (neq (length$ ?b) 0))  ;; bonus-nodes is not empty
    =>
    (bind ?conditions (create$ ?s2 ?n))  ;;all conditions that are true
    (bind ?s3 (list-subtract ?conditions ?s1 ))  ;;remove symptoms that are not in the query
    (printout t ?c " " ?s1 " " ?s3 crlf)
    (if (eq ?c "Caida_Servidor") then
        (bind ?var 1)
    else
        (bind ?var 0)
    )
    (bind ?result (calculate-probability-function ?c ?s1 ?s3 ?var))
    (printout t "answer is: " ?result crlf)
    (retract ?ready)
)
