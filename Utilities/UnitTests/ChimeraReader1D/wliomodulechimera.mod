V28 :0x14 wliomodulechimera
51 ../../../Distributions/Source/wlIOModuleCHIMERA.f90 S622 0
03/12/2015  00:14:51
use wlkindmodule private
enduse
D 56 21 9 1 14 17 1 1 0 0 1
 3 15 3 3 15 16
D 59 21 9 1 18 21 1 1 0 0 1
 3 19 3 3 19 20
D 62 21 9 1 22 25 1 1 0 0 1
 3 23 3 3 23 24
S 622 24 0 0 0 9 1 0 5031 10005 0 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 wliomodulechimera
S 624 23 0 0 0 9 626 622 5062 4 0 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 622 0 0 0 0 dp
R 626 16 1 wlkindmodule dp
S 627 27 0 0 0 9 628 622 5065 0 0 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 622 0 0 0 0 readchimeraprofile1d
S 628 23 5 0 0 0 635 622 5065 0 0 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 readchimeraprofile1d
S 629 1 3 1 0 28 1 628 5086 4 43000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 filename
S 630 6 3 1 0 6 1 628 5095 800004 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 maxzone
S 631 7 3 2 0 56 1 628 5103 20000004 10003000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 rho
S 632 7 3 2 0 59 1 628 5107 20000004 10003000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 t
S 633 7 3 2 0 62 1 628 5109 20000004 10003000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ye
S 634 1 3 1 0 6 1 628 5112 80000004 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 skiplinesoption
S 635 14 5 0 0 0 1 628 5065 20000000 400000 A 0 0 0 0 B 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 14 0 622 0 0 0 0 readchimeraprofile1d
F 635 6 629 630 631 632 633 634
S 636 6 1 0 0 6 1 628 5128 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_0
S 637 6 1 0 0 6 1 628 5134 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_2
S 638 6 1 0 0 6 1 628 5140 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_3
S 639 6 1 0 0 6 1 628 5146 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_e_19
S 640 6 1 0 0 6 1 628 5153 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_4
S 641 6 1 0 0 6 1 628 5159 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_6
S 642 6 1 0 0 6 1 628 5165 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_7
S 643 6 1 0 0 6 1 628 5171 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_e_26
S 644 6 1 0 0 6 1 628 5178 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_8
S 645 6 1 0 0 6 1 628 5184 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_10
S 646 6 1 0 0 6 1 628 5191 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_b_11
S 647 6 1 0 0 6 1 628 5198 40800006 3000 A 0 0 0 0 B 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 z_e_33
A 14 1 0 0 0 6 638 0 0 0 0 0 0 0 0 0 0 0 0 0
A 15 1 0 0 0 6 636 0 0 0 0 0 0 0 0 0 0 0 0 0
A 16 1 0 0 0 6 639 0 0 0 0 0 0 0 0 0 0 0 0 0
A 17 1 0 0 0 6 637 0 0 0 0 0 0 0 0 0 0 0 0 0
A 18 1 0 0 0 6 642 0 0 0 0 0 0 0 0 0 0 0 0 0
A 19 1 0 0 0 6 640 0 0 0 0 0 0 0 0 0 0 0 0 0
A 20 1 0 0 0 6 643 0 0 0 0 0 0 0 0 0 0 0 0 0
A 21 1 0 0 0 6 641 0 0 0 0 0 0 0 0 0 0 0 0 0
A 22 1 0 0 0 6 646 0 0 0 0 0 0 0 0 0 0 0 0 0
A 23 1 0 0 0 6 644 0 0 0 0 0 0 0 0 0 0 0 0 0
A 24 1 0 0 0 6 647 0 0 0 0 0 0 0 0 0 0 0 0 0
A 25 1 0 0 0 6 645 0 0 0 0 0 0 0 0 0 0 0 0 0
Z
Z
