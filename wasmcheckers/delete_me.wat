(module
  ;; The 1 means to allocate at least one 64KB page of memory.
  ;; Memory can grow at the request of either the wasm module or the host.
  (memory $mem 1)

  ;; immutable global variables
  (global $WHITE i32 (i32.const 2))
  (global $BLACK i32 (i32.const 1))
  (global $CROWN i32 (i32.const 4))

  (func $indexForPosition (param $x i32) (param $y i32) (result i32)
        (i32.add
          (i32.mul
            (i32.const 8)
            (get_local $y))
          (get_local $x)))

  ;; Linear memory
  ;; Offset = (x + y * 8) * 4
  ;; Example offsetForPosition(1, 2) => (1 + 2 * 8) * 4 => 68
  (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
        (i32.mul
          (call $indexForPosition (get_local $x) (get_local $y))
          (i32.const 4)))

  ;; Determine if a piece has been crowned
  (func $isCrowned (param $piece i32) (result i32)
        (i32.eq
          (i32.and (get_local $piece) (get_global $CROWN))
          (get_global $CROWN)))

  ;; Determine if a piece is white
  (func $isWhite (param $piece i32) (result i32)
        (i32.eq
          (i32.and (get_local $piece) (get_global $WHITE))
          (get_global $WHITE)))

  ;; Determine if a piece is black
  (func $isBlack (param $piece i32) (result i32)
        (i32.eq
          (i32.and (get_local $piece) (get_global $BLACK))
          (get_global $BLACK)))

  ;; Add a crown to a given piece (no mutation)
  (func $withCrown (param $piece i32) (result i32)
        (i32.or (get_local $piece) (get_global $CROWN)))

  ;; Remove a crown from a given piece (no mutation)
  (func $withoutCrown (param $piece i32) (result i32)
        (i32.and (get_local $piece) (i32.const 3)))

  ;; Set a piece on the board
  (func $setPiece (param $x i32) (param $y i32) (param $piece i32)
        ;; Example: to store a white piece at grid position (5, 5) you would
        ;; do: `(i32.store 200 2)`
        (i32.store                 ;; store a 32-bit integer
          (call $offsetForPosition ;; the memory address to use
                (get_local $x)
                (get_local $y))
          (get_local $piece)))

  ;; Get a piece from the board. Out of range causes a trap.
  (func $getPiece (param $x i32) (param $y i32) (result i32)
        (if (result i32)
          ;; `block` wraps one or more statements. `i32` is the return
          ;; type of the block(?). Kind of like an anon function.
          (block (result i32)
                 (i32.and
                   (call $inRange
                         (i32.const 0)
                         (i32.const 7)
                         (get_local $x))
                   (call $inRange
                         (i32.const 0)
                         (i32.const 7)
                         (get_local $y))))
          (then
            (i32.load
              (call $offsetForPosition
                    (get_local $x)
                    (get_local $y))))
          (else
            (unreachable))))

  ;; Detect if values are within range (inclusive high and low)
  (func $inRange (param $low i32) (param $high i32)
        (param $value i32) (result i32)
        (i32.and
          (i32.ge_s (get_local $value) (get_local $low))
          (i32.le_s (get_local $value) (get_local $high))))

  ;;   (export "offsetForPosition" (func $offsetForPosition))
  ;;   (export "isCrowned" (func $isCrowned))
  ;;   (export "isWhite" (func $isWhite))
  ;;   (export "isBlack" (func $isBlack))
  ;;   (export "withCrown" (func $withCrown))
  ;;   (export "withoutCrown" (func $withoutCrown))
  )
