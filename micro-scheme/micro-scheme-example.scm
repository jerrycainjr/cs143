(4 5 2 1 (and lambda 203 foo x (if if if)))
(define translate 
  (lambda (list delta)
    (map (lambda (num) (add num delta)) list)))

    