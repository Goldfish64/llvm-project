; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Test that the strstr library call simplifier works correctly.
;
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

@.str = private constant [1 x i8] zeroinitializer
@.str1 = private constant [2 x i8] c"a\00"
@.str2 = private constant [6 x i8] c"abcde\00"
@.str3 = private constant [4 x i8] c"bcd\00"

declare i8* @strstr(i8*, i8*)

; Check strstr(str, "") -> str.

define i8* @test_simplify1(i8* %str) {
; CHECK-LABEL: @test_simplify1(
; CHECK-NEXT:    ret i8* [[STR:%.*]]
;
  %pat = getelementptr inbounds [1 x i8], [1 x i8]* @.str, i32 0, i32 0
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  ret i8* %ret
}

; Check strstr(str, "a") -> strchr(str, 'a').

define i8* @test_simplify2(i8* %str) {
; CHECK-LABEL: @test_simplify2(
; CHECK-NEXT:    [[STRCHR:%.*]] = call i8* @strchr(i8* noundef nonnull dereferenceable(1) [[STR:%.*]], i32 97) #[[ATTR1:[0-9]+]]
; CHECK-NEXT:    ret i8* [[STRCHR]]
;
  %pat = getelementptr inbounds [2 x i8], [2 x i8]* @.str1, i32 0, i32 0
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  ret i8* %ret
}

; Check strstr("abcde", "bcd") -> "abcde" + 1.

define i8* @test_simplify3() {
; CHECK-LABEL: @test_simplify3(
; CHECK-NEXT:    ret i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str2, i64 0, i64 1)
;
  %str = getelementptr inbounds [6 x i8], [6 x i8]* @.str2, i32 0, i32 0
  %pat = getelementptr inbounds [4 x i8], [4 x i8]* @.str3, i32 0, i32 0
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  ret i8* %ret
}

; Check strstr(str, str) -> str.

define i8* @test_simplify4(i8* %str) {
; CHECK-LABEL: @test_simplify4(
; CHECK-NEXT:    ret i8* [[STR:%.*]]
;
  %ret = call i8* @strstr(i8* %str, i8* %str)
  ret i8* %ret
}

; Check strstr(str, pat) == str -> strncmp(str, pat, strlen(str)) == 0.

define i1 @test_simplify5(i8* %str, i8* %pat) {
; CHECK-LABEL: @test_simplify5(
; CHECK-NEXT:    [[STRLEN:%.*]] = call i64 @strlen(i8* nocapture noundef nonnull dereferenceable(1) [[PAT:%.*]]) #[[ATTR1]]
; CHECK-NEXT:    [[STRNCMP:%.*]] = call i32 @strncmp(i8* nocapture [[STR:%.*]], i8* nocapture [[PAT]], i64 [[STRLEN]]) #[[ATTR1]]
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[STRNCMP]], 0
; CHECK-NEXT:    ret i1 [[CMP1]]
;
  %ret = call i8* @strstr(i8* %str, i8* %pat)
  %cmp = icmp eq i8* %ret, %str
  ret i1 %cmp
}

define i8* @test1(i8* %str1, i8* %str2) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @strstr(i8* noundef nonnull dereferenceable(1) [[STR1:%.*]], i8* noundef nonnull dereferenceable(1) [[STR2:%.*]])
; CHECK-NEXT:    ret i8* [[RET]]
;
  %ret = call i8* @strstr(i8* %str1, i8* %str2)
  ret i8* %ret
}

define i8* @test2(i8* %str1, i8* %str2) null_pointer_is_valid {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @strstr(i8* noundef [[STR1:%.*]], i8* noundef [[STR2:%.*]])
; CHECK-NEXT:    ret i8* [[RET]]
;
  %ret = call i8* @strstr(i8* %str1, i8* %str2)
  ret i8* %ret
}
