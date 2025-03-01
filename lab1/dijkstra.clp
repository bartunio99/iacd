;; Define node template
(deftemplate node
    (slot name)
)

;; Define edge template
(deftemplate edge
    (slot origin)
    (slot destination)
    (slot value)
)

;; Define distance template
(deftemplate distance
    (slot node)
    (slot value)
)

;; Define nodes of the graph
(deffacts nodes
    (node (name A))
    (node (name B))
    (node (name C))
    (node (name D))
    (node (name E))
    (node (name F))
)

;; Define graph as list of edges
(deffacts graph
    (edge (origin A) (destination B) (value 10))
    (edge (origin A) (destination C) (value 20))
    (edge (origin B) (destination D) (value 50))
    (edge (origin B) (destination E) (value 10))
    (edge (origin C) (destination D) (value 20))
    (edge (origin C) (destination E) (value 33))
    (edge (origin D) (destination E) (value 20))
    (edge (origin D) (destination F) (value 2))
    (edge (origin E) (destination F) (value 1))    
)

;;get start node from user
(deffunction get-start-node()
    (printout t "Input starting node: " crlf)
    (return (read))
)

;;initialize distances
(defrule initialize-distances
    =>
    (assert (number-of-edges 8))
    (bind ?n (get-start-node))
    (foreach ?f (find-all-facts ((?f node)) TRUE)
        (bind ?name (fact-slot-value ?f name))
        (if (neq ?name ?n) then
            (assert (distance (node ?name) (value 99999)))
        )
        
    )
    (assert (distance (node ?n) (value 0)))
    (assert (distances-initialized))
)

(defrule update-distances
    ?e <- (number-of-edges ?n)
    (distances-initialized)
    (distance (node ?n1) (value ?v1))
    (edge (origin ?n1) (destination ?n2) (value ?v2))
    ?d <- (distance (node ?n2) (value ?v3))
    (test (< (+ ?v1 ?v2) ?v3))
    =>
    (retract ?d)
    (retract ?e)
    (assert (number-of-edges (- ?n 1)))
    (assert (distance (node ?n2) (value (+ ?v1 ?v2))))

    (if (= (- ?n 1) 0) then
        (assert (distances-finalized))
    )
)

(defrule print-distances
    (distances-finalized)
    (distance (node ?n) (value ?v))
    =>
    (printout t "distance to (" ?n ") is: " ?v crlf)
)
    