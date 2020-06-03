;; Melih Kurtaran CS305 Extra Homework 2
;; If it gets an error, it displays an error message and continue with the same environment

(define get-operator (lambda (op-symbol env) 
  (cond 
    ((equal? op-symbol '+) +)
    ((equal? op-symbol '-) -)
    ((equal? op-symbol '*) *)
    ((equal? op-symbol '/) /)
    (else  (display "cs305: ERROR (s7-interpreter cannot evaluate the statement)\n\n") (repl env)))))

(define define-stmt? (lambda (e)
    ;; An expression is a define statement
    ;; if it is a list, and the first element
    ;; is define, the second element is a symbol,
    ;; and the third element is an expression.
    (and (list? e) (= (length e) 3) (equal? (car e) 'define) (symbol? (cadr e)))))

(define let-param-correct? (lambda (e)
	(if (list? e)
		(if (null? e) 
			#t
			(if (= (length (car e)) 2)
				(let-param-correct? (cdr e)) 
				#f
			)
		)
		#f
	)
))

(define cond-param-correct? (lambda (e)
(if (null? e) #f
	(if (and (list? (car e)) (= (length (car e)) 2))
		(if (equal? (caar e) 'else)
			(if (null? (cdr e)) #t #f)
		       	(cond-param-correct? (cdr e))
		)
		#f
	))
))

(define letstar-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'let*) (= (length e) 3) (let-param-correct? (cadr e)))))

(define let-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'let) (= (length e) 3) (let-param-correct? (cadr e)))))

(define if-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'if) (= (length e) 4))))

(define cond-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'cond) (> (length e) 2) (cond-param-correct? (cdr e)))))

(define get-value (lambda (var old-env new-env)
    (cond
      ((null? new-env) (display "cs305: ERROR (unbound variable)\n\n") (repl old-env))

      ((equal? (caar new-env) var) (cdar new-env))

      (else (get-value var old-env (cdr new-env))))))

(define extend-env (lambda (var val old-env)
      ;; Add the new variable binding to the 
      ;; beginning of the old environment.
      (cons (cons var val) old-env)))

(define repl (lambda (env)
  (let* (
         ; first print out some prompt
         (dummy1 (display "cs305> "))

         ; READ an expression
         (expr (read))

         ; Form the new environment
         (new-env (if (define-stmt? expr)
                      (extend-env (cadr expr) (s7-interpret (caddr expr) env) env)
                      env))

         ; Evaluate the expression read
         (val (if (define-stmt? expr)
                  (cadr expr)
                  (s7-interpret expr env)))

         ; PRINT the value evaluated together
         ; with a prompt as MIT interpreter does
         (dummy2 (display "cs305: "))
         (dummy3 (display val))

         ; get ready for the next prompt
         (dummy4 (newline))
         (dummy4 (newline)))
     (repl new-env))))

(define s7-interpret (lambda (e env)
  (cond 
    ;; If the input expression is a number, then
    ;; the value of the expression is that number.
    ((number? e) e)

    ;; If the input expression is a symbol, then
    ;; get the current value binding of this variable.
    ((symbol? e) (get-value e env env))

    ;; Otherwise, we must see a list.
    ((not (list? e)) 
	(display "cs305: ERROR (s7-interpreter cannot evaluate the statement)\n\n") (repl env) )

    ;; If empty list, return it back
    ((null? e) e)

    ;; if-statement
    ((if-stmt? e) (if (eq? (s7-interpret (cadr e) env) 0)
            ( s7-interpret (cadddr e) env)
                ( s7-interpret (caddr e) env)))
  
    ;; cond statement
    ((cond-stmt? e) 
	(if (eq? (length e) 3) 
		(if (eq? (s7-interpret (caadr e) env) 0) (s7-interpret (car (cdaddr e)) env) ;base case (if cond only has one statement and else st.)
		(s7-interpret (cadadr e) env))
		;cond will be converted to nested if statements cond -> (if ... (if ... (if ... 
		(let ((if-cond  (caadr e)) (then (cadadr e)) (else-part (cons 'cond (cddr e))) ) 
			(let ((c (list 'if if-cond then else-part))) (s7-interpret c env)))))

    ;; let statement
    ((let-stmt? e)
      (let ((names (map car  (cadr e)))
            (exprs (map cadr (cadr e))))
           (let ((vals (map (lambda (expr) (s7-interpret expr env)) exprs)))
           	(let ((new-env (append (map cons names vals) env)))
            	(s7-interpret (caddr e) new-env)))))

    ;; let-star statement
    ((letstar-stmt? e) (if (<= (length (cadr e)) 1)
			 (let ((l (list 'let (cadr e) (caddr e)))) ;if list has only one element or empty, it will be same as let   
			    (let ((names (map car  (cadr e)))
	            		(exprs (map cadr (cadr e))))
        	   		(let ((vals (map (lambda (expr) (s7-interpret expr env)) exprs)))
                		(let ((new-env (append (map cons names vals) env)))
                		(s7-interpret (caddr e) new-env)))))
			 ;if list has more than one element it will be converted to nested let statements
			 ; (let*  --> (let (let (let (...
			(let ((first (list 'let (list (caadr e)))) (rest (list 'let* (cdadr e) (caddr e))))
     								(let ((l (append first (list rest)))) (let ((names (map car (cadr l))) (inits (map cadr (cadr l))))
     									(let ((vals (map (lambda (init) (s7-interpret init env)) inits)))
     										(let ((new-env (append (map cons names vals) env)))
												(s7-interpret (caddr l) new-env))))))
			))
			 
    ;; First evaluate the value of the operands
    ;; and the procedure of the expression.
    (else 
       (let ((operands (map s7-interpret (cdr e) (make-list (length (cdr e)) env)))
             (operator (get-operator (car e) env)))

         ;; And finally apply the operator to the 
         ;; values of the operands
         (apply operator operands))))))

(define cs305 (lambda () (repl '())))
