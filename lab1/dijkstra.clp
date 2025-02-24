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



;; Initialize distances
(defrule distances
    (declare (salience 100)) ;; High priority
    =>
    (assert (distance (node A) (value 0)))
    (assert (distance (node B) (value 99999)))
    (assert (distance (node C) (value 99999)))
    (assert (distance (node D) (value 99999)))
    (assert (distance (node E) (value 99999)))
    (assert (distance (node F) (value 99999)))
)

;; Update distances - Dijkstra's algorithm
(defrule update-distances
    (distance (node ?n1) (value ?v1))
    (edge (origin ?n1) (destination ?n2) (value ?v2))
    ?d <- (distance (node ?n2) (value ?v3))
    (test (< (+ ?v1 ?v2) ?v3))
    =>
    (retract ?d)
    (assert (distance (node ?n2) (value (+ ?v1 ?v2))))
)

