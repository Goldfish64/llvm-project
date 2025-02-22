; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Test that the strchr library call simplifier works correctly.
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32"

@hello = constant [14 x i8] c"hello world\5Cn\00"
@null = constant [1 x i8] zeroinitializer
@newlines = constant [3 x i8] c"\0D\0A\00"
@chp = global i8* zeroinitializer

declare i8* @strchr(i8*, i32)

define void @test_simplify1() {
; CHECK-LABEL: @test_simplify1(
; CHECK-NEXT:    store i8* getelementptr inbounds ([14 x i8], [14 x i8]* @hello, i32 0, i32 6), i8** @chp, align 4
; CHECK-NEXT:    ret void
;

  %str = getelementptr [14 x i8], [14 x i8]* @hello, i32 0, i32 0
  %dst = call i8* @strchr(i8* %str, i32 119)
  store i8* %dst, i8** @chp
  ret void
}

define void @test_simplify2() {
; CHECK-LABEL: @test_simplify2(
; CHECK-NEXT:    store i8* null, i8** @chp, align 4
; CHECK-NEXT:    ret void
;

  %str = getelementptr [1 x i8], [1 x i8]* @null, i32 0, i32 0
  %dst = call i8* @strchr(i8* %str, i32 119)
  store i8* %dst, i8** @chp
  ret void
}

define void @test_simplify3() {
; CHECK-LABEL: @test_simplify3(
; CHECK-NEXT:    store i8* getelementptr inbounds ([14 x i8], [14 x i8]* @hello, i32 0, i32 13), i8** @chp, align 4
; CHECK-NEXT:    ret void
;

  %src = getelementptr [14 x i8], [14 x i8]* @hello, i32 0, i32 0
  %dst = call i8* @strchr(i8* %src, i32 0)
  store i8* %dst, i8** @chp
  ret void
}

define void @test_simplify4(i32 %chr) {
; CHECK-LABEL: @test_simplify4(
; CHECK-NEXT:    [[MEMCHR:%.*]] = call i8* @memchr(i8* noundef nonnull dereferenceable(14) getelementptr inbounds ([14 x i8], [14 x i8]* @hello, i32 0, i32 0), i32 [[CHR:%.*]], i32 14) #[[ATTR1:[0-9]+]]
; CHECK-NEXT:    store i8* [[MEMCHR]], i8** @chp, align 4
; CHECK-NEXT:    ret void
;

  %src = getelementptr [14 x i8], [14 x i8]* @hello, i32 0, i32 0
  %dst = call i8* @strchr(i8* %src, i32 %chr)
  store i8* %dst, i8** @chp
  ret void
}

define void @test_simplify5() {
; CHECK-LABEL: @test_simplify5(
; CHECK-NEXT:    store i8* getelementptr inbounds ([14 x i8], [14 x i8]* @hello, i32 0, i32 13), i8** @chp, align 4
; CHECK-NEXT:    ret void
;

  %src = getelementptr [14 x i8], [14 x i8]* @hello, i32 0, i32 0
  %dst = call i8* @strchr(i8* %src, i32 65280)
  store i8* %dst, i8** @chp
  ret void
}

; Check transformation strchr(p, 0) -> p + strlen(p)
define void @test_simplify6(i8* %str) {
; CHECK-LABEL: @test_simplify6(
; CHECK-NEXT:    [[STRLEN:%.*]] = call i32 @strlen(i8* nocapture noundef nonnull dereferenceable(1) [[STR:%.*]]) #[[ATTR1]]
; CHECK-NEXT:    [[STRCHR:%.*]] = getelementptr i8, i8* [[STR]], i32 [[STRLEN]]
; CHECK-NEXT:    store i8* [[STRCHR]], i8** @chp, align 4
; CHECK-NEXT:    ret void
;

  %dst = call i8* @strchr(i8* %str, i32 0)
  store i8* %dst, i8** @chp
  ret void
}

; Check transformation strchr("\r\n", C) != nullptr -> (C & 9217) != 0
define i1 @test_simplify7(i32 %C) {
; CHECK-LABEL: @test_simplify7(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 [[C:%.*]] to i16
; CHECK-NEXT:    [[TMP2:%.*]] = and i16 [[TMP1]], 255
; CHECK-NEXT:    [[MEMCHR_BOUNDS:%.*]] = icmp ult i16 [[TMP2]], 16
; CHECK-NEXT:    [[TMP3:%.*]] = shl i16 1, [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = and i16 [[TMP3]], 9217
; CHECK-NEXT:    [[MEMCHR_BITS:%.*]] = icmp ne i16 [[TMP4]], 0
; CHECK-NEXT:    [[MEMCHR1:%.*]] = and i1 [[MEMCHR_BOUNDS]], [[MEMCHR_BITS]]
; CHECK-NEXT:    ret i1 [[MEMCHR1]]
;

  %dst = call i8* @strchr(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @newlines, i64 0, i64 0), i32 %C)
  %cmp = icmp ne i8* %dst, null
  ret i1 %cmp
}

define i8* @test1(i8* %str, i32 %c) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @strchr(i8* noundef nonnull dereferenceable(1) [[STR:%.*]], i32 [[C:%.*]])
; CHECK-NEXT:    ret i8* [[RET]]
;

  %ret = call i8* @strchr(i8* %str, i32 %c)
  ret i8* %ret
}

define i8* @test2(i8* %str, i32 %c) null_pointer_is_valid {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @strchr(i8* noundef [[STR:%.*]], i32 [[C:%.*]])
; CHECK-NEXT:    ret i8* [[RET]]
;

  %ret = call i8* @strchr(i8* %str, i32 %c)
  ret i8* %ret
}
