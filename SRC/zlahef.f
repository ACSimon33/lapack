*> \brief \b ZLAHEF computes a partial factorization of a complex Hermitian indefinite matrix using the Bunch-Kaufman diagonal pivoting method (blocked algorithm, calling Level 3 BLAS).
*
*  =========== DOCUMENTATION ===========
*
* Online html documentation available at
*            http://www.netlib.org/lapack/explore-html/
*
*> Download ZLAHEF + dependencies
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.tgz?format=tgz&filename=/lapack/lapack_routine/zlahef.f">
*> [TGZ]</a>
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.zip?format=zip&filename=/lapack/lapack_routine/zlahef.f">
*> [ZIP]</a>
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.txt?format=txt&filename=/lapack/lapack_routine/zlahef.f">
*> [TXT]</a>
*
*  Definition:
*  ===========
*
*       SUBROUTINE ZLAHEF( UPLO, N, NB, KB, A, LDA, IPIV, W, LDW, INFO )
*
*       .. Scalar Arguments ..
*       CHARACTER          UPLO
*       INTEGER            INFO, KB, LDA, LDW, N, NB
*       ..
*       .. Array Arguments ..
*       INTEGER            IPIV( * )
*       COMPLEX*16         A( LDA, * ), W( LDW, * )
*       ..
*
*
*> \par Purpose:
*  =============
*>
*> \verbatim
*>
*> ZLAHEF computes a partial factorization of a complex Hermitian
*> matrix A using the Bunch-Kaufman diagonal pivoting method. The
*> partial factorization has the form:
*>
*> A  =  ( I  U12 ) ( A11  0  ) (  I      0     )  if UPLO = 'U', or:
*>       ( 0  U22 ) (  0   D  ) ( U12**H U22**H )
*>
*> A  =  ( L11  0 ) (  D   0  ) ( L11**H L21**H )  if UPLO = 'L'
*>       ( L21  I ) (  0  A22 ) (  0      I     )
*>
*> where the order of D is at most NB. The actual order is returned in
*> the argument KB, and is either NB or NB-1, or N if N <= NB.
*> Note that U**H denotes the conjugate transpose of U.
*>
*> ZLAHEF is an auxiliary routine called by ZHETRF. It uses blocked code
*> (calling Level 3 BLAS) to update the submatrix A11 (if UPLO = 'U') or
*> A22 (if UPLO = 'L').
*> \endverbatim
*
*  Arguments:
*  ==========
*
*> \param[in] UPLO
*> \verbatim
*>          UPLO is CHARACTER*1
*>          Specifies whether the upper or lower triangular part of the
*>          Hermitian matrix A is stored:
*>          = 'U':  Upper triangular
*>          = 'L':  Lower triangular
*> \endverbatim
*>
*> \param[in] N
*> \verbatim
*>          N is INTEGER
*>          The order of the matrix A.  N >= 0.
*> \endverbatim
*>
*> \param[in] NB
*> \verbatim
*>          NB is INTEGER
*>          The maximum number of columns of the matrix A that should be
*>          factored.  NB should be at least 2 to allow for 2-by-2 pivot
*>          blocks.
*> \endverbatim
*>
*> \param[out] KB
*> \verbatim
*>          KB is INTEGER
*>          The number of columns of A that were actually factored.
*>          KB is either NB-1 or NB, or N if N <= NB.
*> \endverbatim
*>
*> \param[in,out] A
*> \verbatim
*>          A is COMPLEX*16 array, dimension (LDA,N)
*>          On entry, the Hermitian matrix A.  If UPLO = 'U', the leading
*>          n-by-n upper triangular part of A contains the upper
*>          triangular part of the matrix A, and the strictly lower
*>          triangular part of A is not referenced.  If UPLO = 'L', the
*>          leading n-by-n lower triangular part of A contains the lower
*>          triangular part of the matrix A, and the strictly upper
*>          triangular part of A is not referenced.
*>          On exit, A contains details of the partial factorization.
*> \endverbatim
*>
*> \param[in] LDA
*> \verbatim
*>          LDA is INTEGER
*>          The leading dimension of the array A.  LDA >= max(1,N).
*> \endverbatim
*>
*> \param[out] IPIV
*> \verbatim
*>          IPIV is INTEGER array, dimension (N)
*>          Details of the interchanges and the block structure of D.
*>
*>          If UPLO = 'U':
*>             Only the last KB elements of IPIV are set.
*>
*>             If IPIV(k) > 0, then rows and columns k and IPIV(k) were
*>             interchanged and D(k,k) is a 1-by-1 diagonal block.
*>
*>             If IPIV(k) = IPIV(k-1) < 0, then rows and columns
*>             k-1 and -IPIV(k) were interchanged and D(k-1:k,k-1:k)
*>             is a 2-by-2 diagonal block.
*>
*>          If UPLO = 'L':
*>             Only the first KB elements of IPIV are set.
*>
*>             If IPIV(k) > 0, then rows and columns k and IPIV(k) were
*>             interchanged and D(k,k) is a 1-by-1 diagonal block.
*>
*>             If IPIV(k) = IPIV(k+1) < 0, then rows and columns
*>             k+1 and -IPIV(k) were interchanged and D(k:k+1,k:k+1)
*>             is a 2-by-2 diagonal block.
*> \endverbatim
*>
*> \param[out] W
*> \verbatim
*>          W is COMPLEX*16 array, dimension (LDW,NB)
*> \endverbatim
*>
*> \param[in] LDW
*> \verbatim
*>          LDW is INTEGER
*>          The leading dimension of the array W.  LDW >= max(1,N).
*> \endverbatim
*>
*> \param[out] INFO
*> \verbatim
*>          INFO is INTEGER
*>          = 0: successful exit
*>          > 0: if INFO = k, D(k,k) is exactly zero.  The factorization
*>               has been completed, but the block diagonal matrix D is
*>               exactly singular.
*> \endverbatim
*
*  Authors:
*  ========
*
*> \author Univ. of Tennessee
*> \author Univ. of California Berkeley
*> \author Univ. of Colorado Denver
*> \author NAG Ltd.
*
*> \ingroup lahef
*
*> \par Contributors:
*  ==================
*>
*> \verbatim
*>
*>  December 2016,  Igor Kozachenko,
*>                  Computer Science Division,
*>                  University of California, Berkeley
*> \endverbatim
*
*  =====================================================================
      SUBROUTINE ZLAHEF( UPLO, N, NB, KB, A, LDA, IPIV, W, LDW,
     $                   INFO )
*
*  -- LAPACK computational routine --
*  -- LAPACK is a software package provided by Univ. of Tennessee,    --
*  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
*
*     .. Scalar Arguments ..
      CHARACTER          UPLO
      INTEGER            INFO, KB, LDA, LDW, N, NB
*     ..
*     .. Array Arguments ..
      INTEGER            IPIV( * )
      COMPLEX*16         A( LDA, * ), W( LDW, * )
*     ..
*
*  =====================================================================
*
*     .. Parameters ..
      DOUBLE PRECISION   ZERO, ONE
      PARAMETER          ( ZERO = 0.0D+0, ONE = 1.0D+0 )
      COMPLEX*16         CONE
      PARAMETER          ( CONE = ( 1.0D+0, 0.0D+0 ) )
      DOUBLE PRECISION   EIGHT, SEVTEN
      PARAMETER          ( EIGHT = 8.0D+0, SEVTEN = 17.0D+0 )
*     ..
*     .. Local Scalars ..
      INTEGER            IMAX, J, JJ, JMAX, JP, K, KK, KKW, KP,
     $                   KSTEP, KW
      DOUBLE PRECISION   ABSAKK, ALPHA, COLMAX, R1, ROWMAX, T
      COMPLEX*16         D11, D21, D22, Z
*     ..
*     .. External Functions ..
      LOGICAL            LSAME
      INTEGER            IZAMAX
      EXTERNAL           LSAME, IZAMAX
*     ..
*     .. External Subroutines ..
      EXTERNAL           ZCOPY, ZDSCAL, ZGEMMTR, ZGEMV, ZLACGV,
     $                   ZSWAP
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          ABS, DBLE, DCONJG, DIMAG, MAX, MIN, SQRT
*     ..
*     .. Statement Functions ..
      DOUBLE PRECISION   CABS1
*     ..
*     .. Statement Function definitions ..
      CABS1( Z ) = ABS( DBLE( Z ) ) + ABS( DIMAG( Z ) )
*     ..
*     .. Executable Statements ..
*
      INFO = 0
*
*     Initialize ALPHA for use in choosing pivot block size.
*
      ALPHA = ( ONE+SQRT( SEVTEN ) ) / EIGHT
*
      IF( LSAME( UPLO, 'U' ) ) THEN
*
*        Factorize the trailing columns of A using the upper triangle
*        of A and working backwards, and compute the matrix W = U12*D
*        for use in updating A11 (note that conjg(W) is actually stored)
*
*        K is the main loop index, decreasing from N in steps of 1 or 2
*
*        KW is the column of W which corresponds to column K of A
*
         K = N
   10    CONTINUE
         KW = NB + K - N
*
*        Exit from loop
*
         IF( ( K.LE.N-NB+1 .AND. NB.LT.N ) .OR. K.LT.1 )
     $      GO TO 30
*
         KSTEP = 1
*
*        Copy column K of A to column KW of W and update it
*
         CALL ZCOPY( K-1, A( 1, K ), 1, W( 1, KW ), 1 )
         W( K, KW ) = DBLE( A( K, K ) )
         IF( K.LT.N ) THEN
            CALL ZGEMV( 'No transpose', K, N-K, -CONE, A( 1, K+1 ),
     $                  LDA,
     $                  W( K, KW+1 ), LDW, CONE, W( 1, KW ), 1 )
            W( K, KW ) = DBLE( W( K, KW ) )
         END IF
*
*        Determine rows and columns to be interchanged and whether
*        a 1-by-1 or 2-by-2 pivot block will be used
*
         ABSAKK = ABS( DBLE( W( K, KW ) ) )
*
*        IMAX is the row-index of the largest off-diagonal element in
*        column K, and COLMAX is its absolute value.
*        Determine both COLMAX and IMAX.
*
         IF( K.GT.1 ) THEN
            IMAX = IZAMAX( K-1, W( 1, KW ), 1 )
            COLMAX = CABS1( W( IMAX, KW ) )
         ELSE
            COLMAX = ZERO
         END IF
*
         IF( MAX( ABSAKK, COLMAX ).EQ.ZERO ) THEN
*
*           Column K is zero or underflow: set INFO and continue
*
            IF( INFO.EQ.0 )
     $         INFO = K
            KP = K
            A( K, K ) = DBLE( A( K, K ) )
         ELSE
*
*           ============================================================
*
*           BEGIN pivot search
*
*           Case(1)
            IF( ABSAKK.GE.ALPHA*COLMAX ) THEN
*
*              no interchange, use 1-by-1 pivot block
*
               KP = K
            ELSE
*
*              BEGIN pivot search along IMAX row
*
*
*              Copy column IMAX to column KW-1 of W and update it
*
               CALL ZCOPY( IMAX-1, A( 1, IMAX ), 1, W( 1, KW-1 ), 1 )
               W( IMAX, KW-1 ) = DBLE( A( IMAX, IMAX ) )
               CALL ZCOPY( K-IMAX, A( IMAX, IMAX+1 ), LDA,
     $                     W( IMAX+1, KW-1 ), 1 )
               CALL ZLACGV( K-IMAX, W( IMAX+1, KW-1 ), 1 )
               IF( K.LT.N ) THEN
                  CALL ZGEMV( 'No transpose', K, N-K, -CONE,
     $                        A( 1, K+1 ), LDA, W( IMAX, KW+1 ), LDW,
     $                        CONE, W( 1, KW-1 ), 1 )
                  W( IMAX, KW-1 ) = DBLE( W( IMAX, KW-1 ) )
               END IF
*
*              JMAX is the column-index of the largest off-diagonal
*              element in row IMAX, and ROWMAX is its absolute value.
*              Determine only ROWMAX.
*
               JMAX = IMAX + IZAMAX( K-IMAX, W( IMAX+1, KW-1 ), 1 )
               ROWMAX = CABS1( W( JMAX, KW-1 ) )
               IF( IMAX.GT.1 ) THEN
                  JMAX = IZAMAX( IMAX-1, W( 1, KW-1 ), 1 )
                  ROWMAX = MAX( ROWMAX, CABS1( W( JMAX, KW-1 ) ) )
               END IF
*
*              Case(2)
               IF( ABSAKK.GE.ALPHA*COLMAX*( COLMAX / ROWMAX ) ) THEN
*
*                 no interchange, use 1-by-1 pivot block
*
                  KP = K
*
*              Case(3)
               ELSE IF( ABS( DBLE( W( IMAX, KW-1 ) ) ).GE.ALPHA*ROWMAX )
     $                   THEN
*
*                 interchange rows and columns K and IMAX, use 1-by-1
*                 pivot block
*
                  KP = IMAX
*
*                 copy column KW-1 of W to column KW of W
*
                  CALL ZCOPY( K, W( 1, KW-1 ), 1, W( 1, KW ), 1 )
*
*              Case(4)
               ELSE
*
*                 interchange rows and columns K-1 and IMAX, use 2-by-2
*                 pivot block
*
                  KP = IMAX
                  KSTEP = 2
               END IF
*
*
*              END pivot search along IMAX row
*
            END IF
*
*           END pivot search
*
*           ============================================================
*
*           KK is the column of A where pivoting step stopped
*
            KK = K - KSTEP + 1
*
*           KKW is the column of W which corresponds to column KK of A
*
            KKW = NB + KK - N
*
*           Interchange rows and columns KP and KK.
*           Updated column KP is already stored in column KKW of W.
*
            IF( KP.NE.KK ) THEN
*
*              Copy non-updated column KK to column KP of submatrix A
*              at step K. No need to copy element into column K
*              (or K and K-1 for 2-by-2 pivot) of A, since these columns
*              will be later overwritten.
*
               A( KP, KP ) = DBLE( A( KK, KK ) )
               CALL ZCOPY( KK-1-KP, A( KP+1, KK ), 1, A( KP, KP+1 ),
     $                     LDA )
               CALL ZLACGV( KK-1-KP, A( KP, KP+1 ), LDA )
               IF( KP.GT.1 )
     $            CALL ZCOPY( KP-1, A( 1, KK ), 1, A( 1, KP ), 1 )
*
*              Interchange rows KK and KP in last K+1 to N columns of A
*              (columns K (or K and K-1 for 2-by-2 pivot) of A will be
*              later overwritten). Interchange rows KK and KP
*              in last KKW to NB columns of W.
*
               IF( K.LT.N )
     $            CALL ZSWAP( N-K, A( KK, K+1 ), LDA, A( KP, K+1 ),
     $                        LDA )
               CALL ZSWAP( N-KK+1, W( KK, KKW ), LDW, W( KP, KKW ),
     $                     LDW )
            END IF
*
            IF( KSTEP.EQ.1 ) THEN
*
*              1-by-1 pivot block D(k): column kw of W now holds
*
*              W(kw) = U(k)*D(k),
*
*              where U(k) is the k-th column of U
*
*              (1) Store subdiag. elements of column U(k)
*              and 1-by-1 block D(k) in column k of A.
*              (NOTE: Diagonal element U(k,k) is a UNIT element
*              and not stored)
*                 A(k,k) := D(k,k) = W(k,kw)
*                 A(1:k-1,k) := U(1:k-1,k) = W(1:k-1,kw)/D(k,k)
*
*              (NOTE: No need to use for Hermitian matrix
*              A( K, K ) = DBLE( W( K, K) ) to separately copy diagonal
*              element D(k,k) from W (potentially saves only one load))
               CALL ZCOPY( K, W( 1, KW ), 1, A( 1, K ), 1 )
               IF( K.GT.1 ) THEN
*
*                 (NOTE: No need to check if A(k,k) is NOT ZERO,
*                  since that was ensured earlier in pivot search:
*                  case A(k,k) = 0 falls into 2x2 pivot case(4))
*
                  R1 = ONE / DBLE( A( K, K ) )
                  CALL ZDSCAL( K-1, R1, A( 1, K ), 1 )
*
*                 (2) Conjugate column W(kw)
*
                  CALL ZLACGV( K-1, W( 1, KW ), 1 )
               END IF
*
            ELSE
*
*              2-by-2 pivot block D(k): columns kw and kw-1 of W now hold
*
*              ( W(kw-1) W(kw) ) = ( U(k-1) U(k) )*D(k)
*
*              where U(k) and U(k-1) are the k-th and (k-1)-th columns
*              of U
*
*              (1) Store U(1:k-2,k-1) and U(1:k-2,k) and 2-by-2
*              block D(k-1:k,k-1:k) in columns k-1 and k of A.
*              (NOTE: 2-by-2 diagonal block U(k-1:k,k-1:k) is a UNIT
*              block and not stored)
*                 A(k-1:k,k-1:k) := D(k-1:k,k-1:k) = W(k-1:k,kw-1:kw)
*                 A(1:k-2,k-1:k) := U(1:k-2,k:k-1:k) =
*                 = W(1:k-2,kw-1:kw) * ( D(k-1:k,k-1:k)**(-1) )
*
               IF( K.GT.2 ) THEN
*
*                 Factor out the columns of the inverse of 2-by-2 pivot
*                 block D, so that each column contains 1, to reduce the
*                 number of FLOPS when we multiply panel
*                 ( W(kw-1) W(kw) ) by this inverse, i.e. by D**(-1).
*
*                 D**(-1) = ( d11 cj(d21) )**(-1) =
*                           ( d21    d22 )
*
*                 = 1/(d11*d22-|d21|**2) * ( ( d22) (-cj(d21) ) ) =
*                                          ( (-d21) (     d11 ) )
*
*                 = 1/(|d21|**2) * 1/((d11/cj(d21))*(d22/d21)-1) *
*
*                   * ( d21*( d22/d21 ) conj(d21)*(           - 1 ) ) =
*                     (     (      -1 )           ( d11/conj(d21) ) )
*
*                 = 1/(|d21|**2) * 1/(D22*D11-1) *
*
*                   * ( d21*( D11 ) conj(d21)*(  -1 ) ) =
*                     (     (  -1 )           ( D22 ) )
*
*                 = (1/|d21|**2) * T * ( d21*( D11 ) conj(d21)*(  -1 ) ) =
*                                      (     (  -1 )           ( D22 ) )
*
*                 = ( (T/conj(d21))*( D11 ) (T/d21)*(  -1 ) ) =
*                   (               (  -1 )         ( D22 ) )
*
*                 = ( conj(D21)*( D11 ) D21*(  -1 ) )
*                   (           (  -1 )     ( D22 ) ),
*
*                 where D11 = d22/d21,
*                       D22 = d11/conj(d21),
*                       D21 = T/d21,
*                       T = 1/(D22*D11-1).
*
*                 (NOTE: No need to check for division by ZERO,
*                  since that was ensured earlier in pivot search:
*                  (a) d21 != 0, since in 2x2 pivot case(4)
*                      |d21| should be larger than |d11| and |d22|;
*                  (b) (D22*D11 - 1) != 0, since from (a),
*                      both |D11| < 1, |D22| < 1, hence |D22*D11| << 1.)
*
                  D21 = W( K-1, KW )
                  D11 = W( K, KW ) / DCONJG( D21 )
                  D22 = W( K-1, KW-1 ) / D21
                  T = ONE / ( DBLE( D11*D22 )-ONE )
                  D21 = T / D21
*
*                 Update elements in columns A(k-1) and A(k) as
*                 dot products of rows of ( W(kw-1) W(kw) ) and columns
*                 of D**(-1)
*
                  DO 20 J = 1, K - 2
                     A( J, K-1 ) = D21*( D11*W( J, KW-1 )-W( J, KW ) )
                     A( J, K ) = DCONJG( D21 )*
     $                           ( D22*W( J, KW )-W( J, KW-1 ) )
   20             CONTINUE
               END IF
*
*              Copy D(k) to A
*
               A( K-1, K-1 ) = W( K-1, KW-1 )
               A( K-1, K ) = W( K-1, KW )
               A( K, K ) = W( K, KW )
*
*              (2) Conjugate columns W(kw) and W(kw-1)
*
               CALL ZLACGV( K-1, W( 1, KW ), 1 )
               CALL ZLACGV( K-2, W( 1, KW-1 ), 1 )
*
            END IF
*
         END IF
*
*        Store details of the interchanges in IPIV
*
         IF( KSTEP.EQ.1 ) THEN
            IPIV( K ) = KP
         ELSE
            IPIV( K ) = -KP
            IPIV( K-1 ) = -KP
         END IF
*
*        Decrease K and return to the start of the main loop
*
         K = K - KSTEP
         GO TO 10
*
   30    CONTINUE
*
*        Update the upper triangle of A11 (= A(1:k,1:k)) as
*
*        A11 := A11 - U12*D*U12**H = A11 - U12*W**H
*
*        (note that conjg(W) is actually stored)
*
         CALL ZGEMMTR( 'Upper', 'No transpose', 'Transpose', K, N-K,
     $                 -CONE, A( 1, K+1 ), LDA, W( 1, KW+1 ), LDW,
     $                 CONE, A( 1, 1 ), LDA )
*
*        Put U12 in standard form by partially undoing the interchanges
*        in columns k+1:n looping backwards from k+1 to n
*
         J = K + 1
   60    CONTINUE
*
*           Undo the interchanges (if any) of rows JJ and JP at each
*           step J
*
*           (Here, J is a diagonal index)
            JJ = J
            JP = IPIV( J )
            IF( JP.LT.0 ) THEN
               JP = -JP
*              (Here, J is a diagonal index)
               J = J + 1
            END IF
*           (NOTE: Here, J is used to determine row length. Length N-J+1
*           of the rows to swap back doesn't include diagonal element)
            J = J + 1
            IF( JP.NE.JJ .AND. J.LE.N )
     $         CALL ZSWAP( N-J+1, A( JP, J ), LDA, A( JJ, J ), LDA )
         IF( J.LT.N )
     $      GO TO 60
*
*        Set KB to the number of columns factorized
*
         KB = N - K
*
      ELSE
*
*        Factorize the leading columns of A using the lower triangle
*        of A and working forwards, and compute the matrix W = L21*D
*        for use in updating A22 (note that conjg(W) is actually stored)
*
*        K is the main loop index, increasing from 1 in steps of 1 or 2
*
         K = 1
   70    CONTINUE
*
*        Exit from loop
*
         IF( ( K.GE.NB .AND. NB.LT.N ) .OR. K.GT.N )
     $      GO TO 90
*
         KSTEP = 1
*
*        Copy column K of A to column K of W and update it
*
         W( K, K ) = DBLE( A( K, K ) )
         IF( K.LT.N )
     $      CALL ZCOPY( N-K, A( K+1, K ), 1, W( K+1, K ), 1 )
         CALL ZGEMV( 'No transpose', N-K+1, K-1, -CONE, A( K, 1 ),
     $               LDA,
     $               W( K, 1 ), LDW, CONE, W( K, K ), 1 )
         W( K, K ) = DBLE( W( K, K ) )
*
*        Determine rows and columns to be interchanged and whether
*        a 1-by-1 or 2-by-2 pivot block will be used
*
         ABSAKK = ABS( DBLE( W( K, K ) ) )
*
*        IMAX is the row-index of the largest off-diagonal element in
*        column K, and COLMAX is its absolute value.
*        Determine both COLMAX and IMAX.
*
         IF( K.LT.N ) THEN
            IMAX = K + IZAMAX( N-K, W( K+1, K ), 1 )
            COLMAX = CABS1( W( IMAX, K ) )
         ELSE
            COLMAX = ZERO
         END IF
*
         IF( MAX( ABSAKK, COLMAX ).EQ.ZERO ) THEN
*
*           Column K is zero or underflow: set INFO and continue
*
            IF( INFO.EQ.0 )
     $         INFO = K
            KP = K
            A( K, K ) = DBLE( A( K, K ) )
         ELSE
*
*           ============================================================
*
*           BEGIN pivot search
*
*           Case(1)
            IF( ABSAKK.GE.ALPHA*COLMAX ) THEN
*
*              no interchange, use 1-by-1 pivot block
*
               KP = K
            ELSE
*
*              BEGIN pivot search along IMAX row
*
*
*              Copy column IMAX to column K+1 of W and update it
*
               CALL ZCOPY( IMAX-K, A( IMAX, K ), LDA, W( K, K+1 ),
     $                     1 )
               CALL ZLACGV( IMAX-K, W( K, K+1 ), 1 )
               W( IMAX, K+1 ) = DBLE( A( IMAX, IMAX ) )
               IF( IMAX.LT.N )
     $            CALL ZCOPY( N-IMAX, A( IMAX+1, IMAX ), 1,
     $                        W( IMAX+1, K+1 ), 1 )
               CALL ZGEMV( 'No transpose', N-K+1, K-1, -CONE, A( K,
     $                     1 ),
     $                     LDA, W( IMAX, 1 ), LDW, CONE, W( K, K+1 ),
     $                     1 )
               W( IMAX, K+1 ) = DBLE( W( IMAX, K+1 ) )
*
*              JMAX is the column-index of the largest off-diagonal
*              element in row IMAX, and ROWMAX is its absolute value.
*              Determine only ROWMAX.
*
               JMAX = K - 1 + IZAMAX( IMAX-K, W( K, K+1 ), 1 )
               ROWMAX = CABS1( W( JMAX, K+1 ) )
               IF( IMAX.LT.N ) THEN
                  JMAX = IMAX + IZAMAX( N-IMAX, W( IMAX+1, K+1 ), 1 )
                  ROWMAX = MAX( ROWMAX, CABS1( W( JMAX, K+1 ) ) )
               END IF
*
*              Case(2)
               IF( ABSAKK.GE.ALPHA*COLMAX*( COLMAX / ROWMAX ) ) THEN
*
*                 no interchange, use 1-by-1 pivot block
*
                  KP = K
*
*              Case(3)
               ELSE IF( ABS( DBLE( W( IMAX, K+1 ) ) ).GE.ALPHA*ROWMAX )
     $                   THEN
*
*                 interchange rows and columns K and IMAX, use 1-by-1
*                 pivot block
*
                  KP = IMAX
*
*                 copy column K+1 of W to column K of W
*
                  CALL ZCOPY( N-K+1, W( K, K+1 ), 1, W( K, K ), 1 )
*
*              Case(4)
               ELSE
*
*                 interchange rows and columns K+1 and IMAX, use 2-by-2
*                 pivot block
*
                  KP = IMAX
                  KSTEP = 2
               END IF
*
*
*              END pivot search along IMAX row
*
            END IF
*
*           END pivot search
*
*           ============================================================
*
*           KK is the column of A where pivoting step stopped
*
            KK = K + KSTEP - 1
*
*           Interchange rows and columns KP and KK.
*           Updated column KP is already stored in column KK of W.
*
            IF( KP.NE.KK ) THEN
*
*              Copy non-updated column KK to column KP of submatrix A
*              at step K. No need to copy element into column K
*              (or K and K+1 for 2-by-2 pivot) of A, since these columns
*              will be later overwritten.
*
               A( KP, KP ) = DBLE( A( KK, KK ) )
               CALL ZCOPY( KP-KK-1, A( KK+1, KK ), 1, A( KP, KK+1 ),
     $                     LDA )
               CALL ZLACGV( KP-KK-1, A( KP, KK+1 ), LDA )
               IF( KP.LT.N )
     $            CALL ZCOPY( N-KP, A( KP+1, KK ), 1, A( KP+1, KP ),
     $                        1 )
*
*              Interchange rows KK and KP in first K-1 columns of A
*              (columns K (or K and K+1 for 2-by-2 pivot) of A will be
*              later overwritten). Interchange rows KK and KP
*              in first KK columns of W.
*
               IF( K.GT.1 )
     $            CALL ZSWAP( K-1, A( KK, 1 ), LDA, A( KP, 1 ), LDA )
               CALL ZSWAP( KK, W( KK, 1 ), LDW, W( KP, 1 ), LDW )
            END IF
*
            IF( KSTEP.EQ.1 ) THEN
*
*              1-by-1 pivot block D(k): column k of W now holds
*
*              W(k) = L(k)*D(k),
*
*              where L(k) is the k-th column of L
*
*              (1) Store subdiag. elements of column L(k)
*              and 1-by-1 block D(k) in column k of A.
*              (NOTE: Diagonal element L(k,k) is a UNIT element
*              and not stored)
*                 A(k,k) := D(k,k) = W(k,k)
*                 A(k+1:N,k) := L(k+1:N,k) = W(k+1:N,k)/D(k,k)
*
*              (NOTE: No need to use for Hermitian matrix
*              A( K, K ) = DBLE( W( K, K) ) to separately copy diagonal
*              element D(k,k) from W (potentially saves only one load))
               CALL ZCOPY( N-K+1, W( K, K ), 1, A( K, K ), 1 )
               IF( K.LT.N ) THEN
*
*                 (NOTE: No need to check if A(k,k) is NOT ZERO,
*                  since that was ensured earlier in pivot search:
*                  case A(k,k) = 0 falls into 2x2 pivot case(4))
*
                  R1 = ONE / DBLE( A( K, K ) )
                  CALL ZDSCAL( N-K, R1, A( K+1, K ), 1 )
*
*                 (2) Conjugate column W(k)
*
                  CALL ZLACGV( N-K, W( K+1, K ), 1 )
               END IF
*
            ELSE
*
*              2-by-2 pivot block D(k): columns k and k+1 of W now hold
*
*              ( W(k) W(k+1) ) = ( L(k) L(k+1) )*D(k)
*
*              where L(k) and L(k+1) are the k-th and (k+1)-th columns
*              of L
*
*              (1) Store L(k+2:N,k) and L(k+2:N,k+1) and 2-by-2
*              block D(k:k+1,k:k+1) in columns k and k+1 of A.
*              (NOTE: 2-by-2 diagonal block L(k:k+1,k:k+1) is a UNIT
*              block and not stored)
*                 A(k:k+1,k:k+1) := D(k:k+1,k:k+1) = W(k:k+1,k:k+1)
*                 A(k+2:N,k:k+1) := L(k+2:N,k:k+1) =
*                 = W(k+2:N,k:k+1) * ( D(k:k+1,k:k+1)**(-1) )
*
               IF( K.LT.N-1 ) THEN
*
*                 Factor out the columns of the inverse of 2-by-2 pivot
*                 block D, so that each column contains 1, to reduce the
*                 number of FLOPS when we multiply panel
*                 ( W(kw-1) W(kw) ) by this inverse, i.e. by D**(-1).
*
*                 D**(-1) = ( d11 cj(d21) )**(-1) =
*                           ( d21    d22 )
*
*                 = 1/(d11*d22-|d21|**2) * ( ( d22) (-cj(d21) ) ) =
*                                          ( (-d21) (     d11 ) )
*
*                 = 1/(|d21|**2) * 1/((d11/cj(d21))*(d22/d21)-1) *
*
*                   * ( d21*( d22/d21 ) conj(d21)*(           - 1 ) ) =
*                     (     (      -1 )           ( d11/conj(d21) ) )
*
*                 = 1/(|d21|**2) * 1/(D22*D11-1) *
*
*                   * ( d21*( D11 ) conj(d21)*(  -1 ) ) =
*                     (     (  -1 )           ( D22 ) )
*
*                 = (1/|d21|**2) * T * ( d21*( D11 ) conj(d21)*(  -1 ) ) =
*                                      (     (  -1 )           ( D22 ) )
*
*                 = ( (T/conj(d21))*( D11 ) (T/d21)*(  -1 ) ) =
*                   (               (  -1 )         ( D22 ) )
*
*                 = ( conj(D21)*( D11 ) D21*(  -1 ) )
*                   (           (  -1 )     ( D22 ) ),
*
*                 where D11 = d22/d21,
*                       D22 = d11/conj(d21),
*                       D21 = T/d21,
*                       T = 1/(D22*D11-1).
*
*                 (NOTE: No need to check for division by ZERO,
*                  since that was ensured earlier in pivot search:
*                  (a) d21 != 0, since in 2x2 pivot case(4)
*                      |d21| should be larger than |d11| and |d22|;
*                  (b) (D22*D11 - 1) != 0, since from (a),
*                      both |D11| < 1, |D22| < 1, hence |D22*D11| << 1.)
*
                  D21 = W( K+1, K )
                  D11 = W( K+1, K+1 ) / D21
                  D22 = W( K, K ) / DCONJG( D21 )
                  T = ONE / ( DBLE( D11*D22 )-ONE )
                  D21 = T / D21
*
*                 Update elements in columns A(k) and A(k+1) as
*                 dot products of rows of ( W(k) W(k+1) ) and columns
*                 of D**(-1)
*
                  DO 80 J = K + 2, N
                     A( J, K ) = DCONJG( D21 )*
     $                           ( D11*W( J, K )-W( J, K+1 ) )
                     A( J, K+1 ) = D21*( D22*W( J, K+1 )-W( J, K ) )
   80             CONTINUE
               END IF
*
*              Copy D(k) to A
*
               A( K, K ) = W( K, K )
               A( K+1, K ) = W( K+1, K )
               A( K+1, K+1 ) = W( K+1, K+1 )
*
*              (2) Conjugate columns W(k) and W(k+1)
*
               CALL ZLACGV( N-K, W( K+1, K ), 1 )
               CALL ZLACGV( N-K-1, W( K+2, K+1 ), 1 )
*
            END IF
*
         END IF
*
*        Store details of the interchanges in IPIV
*
         IF( KSTEP.EQ.1 ) THEN
            IPIV( K ) = KP
         ELSE
            IPIV( K ) = -KP
            IPIV( K+1 ) = -KP
         END IF
*
*        Increase K and return to the start of the main loop
*
         K = K + KSTEP
         GO TO 70
*
   90    CONTINUE
*
*        Update the lower triangle of A22 (= A(k:n,k:n)) as
*
*        A22 := A22 - L21*D*L21**H = A22 - L21*W**H
*
*        (note that conjg(W) is actually stored)
*
         CALL ZGEMMTR( 'Lower', 'No transpose', 'Transpose', N-K+1,
     $                 K-1, -CONE, A( K, 1 ), LDA, W( K, 1 ), LDW,
     $                 CONE, A( K, K ), LDA )
*
*        Put L21 in standard form by partially undoing the interchanges
*        of rows in columns 1:k-1 looping backwards from k-1 to 1
*
         J = K - 1
  120    CONTINUE
*
*           Undo the interchanges (if any) of rows JJ and JP at each
*           step J
*
*           (Here, J is a diagonal index)
            JJ = J
            JP = IPIV( J )
            IF( JP.LT.0 ) THEN
               JP = -JP
*              (Here, J is a diagonal index)
               J = J - 1
            END IF
*           (NOTE: Here, J is used to determine row length. Length J
*           of the rows to swap back doesn't include diagonal element)
            J = J - 1
            IF( JP.NE.JJ .AND. J.GE.1 )
     $         CALL ZSWAP( J, A( JP, 1 ), LDA, A( JJ, 1 ), LDA )
         IF( J.GT.1 )
     $      GO TO 120
*
*        Set KB to the number of columns factorized
*
         KB = K - 1
*
      END IF
      RETURN
*
*     End of ZLAHEF
*
      END
