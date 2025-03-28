;;define throw template
(deftemplate roll
    (slot number)
    (slot points)
)

;;define a frame template
(deftemplate frame
    (slot number)  ;;which one in the order it is
    (multislot roll-id)
)

;;template to check if points have been processed for each roll
(deftemplate roll-processed
    (slot roll-id)
    (slot is-it-processed)
)

(deffacts rolls
    (roll (number 1) (points 10))
    (roll (number 2) (points 9))
    (roll (number 3) (points 1))
    (roll (number 4) (points 5))
    (roll (number 5) (points 5))
    (roll (number 6) (points 7))
    (roll (number 7) (points 2))
    (roll (number 8) (points 10))
    (roll (number 9) (points 10))
    (roll (number 10) (points 10))
    (roll (number 11) (points 2))
    (roll (number 12) (points 3))
    (roll (number 13) (points 6))
    (roll (number 14) (points 4))
    (roll (number 15) (points 7))
    (roll (number 16) (points 3))
    (roll (number 17) (points 3))
)

(deffacts frames
    (frame (number 1) (roll-id 1))
    (frame (number 2) (roll-id 2 3))
    (frame (number 3) (roll-id 4 5))
    (frame (number 4) (roll-id 6 7))
    (frame (number 5) (roll-id 8))
    (frame (number 6) (roll-id 9))
    (frame (number 7) (roll-id 10))
    (frame (number 8) (roll-id 11 12))
    (frame (number 9) (roll-id 13 14))
    (frame (number 10) (roll-id 15 16 17))
)

(defrule init
    =>
    (assert (points 0))

    ;;assert all rolls as not processed yet
    (assert (roll-processed (roll-id 1) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 2) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 3) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 4) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 5) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 6) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 7) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 8) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 9) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 10) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 11) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 12) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 13) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 14) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 15) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 16) (is-it-processed FALSE)))
    (assert (roll-processed (roll-id 17) (is-it-processed FALSE)))
)

(defrule strike
    ?roll <- (roll (number ?n1) (points ?p1))
    ?roll2 <- (roll (number ?n2) (points ?p2))
    ?roll3 <- (roll (number ?n3) (points ?p3))
    ?processed <- (roll-processed (roll-id ?id) (is-it-processed FALSE))
    ?score <- (points ?sc)
    (test (eq ?id ?n1))
    (test (eq ?p1 10))
    (test (eq ?n2 (+ ?n1 1)))
    (test (eq ?n3 (+ ?n1 2)))
    =>
    (retract ?score)
    (retract ?processed)
    (assert (roll-processed (roll-id ?id) (is-it-processed TRUE)))
    (assert (points (+ ?sc ?p1 ?p2 ?p3)))
)

(defrule spare ;;for two
    ?frame <- (frame (number ?n) (roll-id ?id1 ?id2))
    ?roll <- (roll (number ?id1) (points ?p1))
    ?roll2 <- (roll (number ?id2) (points ?p2))
    ?roll3 <- (roll (number ?n3) (points ?p3))
    ?processed <- (roll-processed (roll-id ?id1) (is-it-processed FALSE))
    ?processed2 <- (roll-processed (roll-id ?id2) (is-it-processed FALSE))
    ?score <- (points ?sc)
    (test (eq ?n3 (+ ?id2 1)))              ;;check if roll3 is after roll2
    (test (eq (+ ?p1 ?p2) 10))              ;;checks if it spare
    =>
    (retract ?score)
    (retract ?processed)
    (retract ?processed2)
    (assert (roll-processed (roll-id ?id1) (is-it-processed TRUE)))
    (assert (roll-processed (roll-id ?id2) (is-it-processed TRUE)))
    (assert (points (+ ?sc ?p1 ?p2 ?p3)))
)

;;calculate points for final frame (if it has 3 members)
(defrule calculate-last-frame 
    ?frame <- (frame (number ?n) (roll-id ?id1 ?id2 ?id3))
    ?roll <- (roll (number ?id1) (points ?p1))
    ?roll2 <- (roll (number ?id2) (points ?p2))
    ?roll3 <- (roll (number ?id3) (points ?p3))
    ?processed <- (roll-processed (roll-id ?id1) (is-it-processed FALSE))
    ?processed2 <- (roll-processed (roll-id ?id2) (is-it-processed FALSE))
    ?processed3 <- (roll-processed (roll-id ?id3) (is-it-processed FALSE))
    ?score <- (points ?sc)
    =>
    (retract ?score)
    (retract ?processed)
    (retract ?processed2)
    (retract ?processed3)
    (assert (roll-processed (roll-id ?id1) (is-it-processed TRUE)))
    (assert (roll-processed (roll-id ?id2) (is-it-processed TRUE)))
    (assert (roll-processed (roll-id ?id3) (is-it-processed TRUE)))
    (assert (points (+ ?sc ?p1 ?p2 ?p3)))
)

;;calculate points for normal frame
(defrule calculate-normal
    ?frame <- (frame (number ?n) (roll-id ?id1 ?id2))
    ?roll <- (roll (number ?id1) (points ?p1))
    ?roll2 <- (roll (number ?id2) (points ?p2))
    ?processed <- (roll-processed (roll-id ?id1) (is-it-processed FALSE))
    ?processed2 <- (roll-processed (roll-id ?id2) (is-it-processed FALSE))
    ?score <- (points ?sc)
    (test (> 10 (+ ?p1 ?p2)))   ;;check that its not spare
    =>
    (retract ?score)
    (retract ?processed)
    (retract ?processed2)
    (assert (roll-processed (roll-id ?id1) (is-it-processed TRUE)))
    (assert (roll-processed (roll-id ?id2) (is-it-processed TRUE)))
    (assert (points (+ ?sc ?p1 ?p2)))
)