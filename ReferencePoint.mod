#parametry
param doplywy {1..3,1..2};
param poziomPoczatkowyWody {1..2};
param minimum {1..2};
param maximum {1..2};
param wydajnosc {1..2};
param przepustowosc {1..2};
param cena > 0 integer;
param wartoscBonusu;
param progBonusu;

#metoda punktu odniesienia
param zyskCel;
param potencjalWytworczyCel;
param epsilon;
param beta;
param lambdaZysk;
param lambdaPotencjalWytworczy;
#/metoda punktu odniesienia

#zmienne
var zuzycieWody {1..3,1..2} >= 0;
var wygenerowanaEnergia {1..3,1..2} >= 0;
var poziomKoncowyWody {0..3,1..2} >= 0;
var zrzut {1..3,1..2} >=0;
var czyBonus {1..3} binary;

#metoda punktu odniesienia
var zysk = sum {okres in 1..3, elektrownia in 1..2} cena * wygenerowanaEnergia[okres,elektrownia] 
   + sum {okres in 1..3} czyBonus[okres] * wartoscBonusu;
var potencjalWytworczy = sum {elektrownia in 1..2} poziomKoncowyWody[3,elektrownia];
var z;
var zZysk;
var zPotencjalWytworczy;

#/metoda punktu odniesienia

#funkcja celu
maximize cel: z + epsilon * (zZysk + zPotencjalWytworczy);

#ograniczenia
subject to ogr_poziomPoczatkowyWody {elektrownia in 1..2}:
	poziomKoncowyWody[0,elektrownia] = poziomPoczatkowyWody[elektrownia];

subject to ogr_poziomKoncowyWody_el_1 {okres in 1..3}:
	poziomKoncowyWody[okres,1] = poziomKoncowyWody[okres-1,1] + doplywy[okres,1] - zuzycieWody[okres,1] - zrzut[okres,1];

subject to ogr_poziomKoncowyWody_el_2 {okres in 1..3}:
	poziomKoncowyWody[okres,2] = poziomKoncowyWody[okres-1,2] + doplywy[okres,2] + 0.5 * zuzycieWody[okres,1] - zuzycieWody[okres,2] - zrzut[okres,2] + zrzut[okres,1];

subject to ogr_minimum {okres in 1..3, elektrownia in 1..2}:
   poziomKoncowyWody[okres,elektrownia] >= minimum[elektrownia];

subject to ogr_wygenerowanaEnergia {okres in 1..3, elektrownia in 1..2}:
   wygenerowanaEnergia[okres,elektrownia] = wydajnosc[elektrownia] * zuzycieWody[okres,elektrownia];

subject to ogr_przepustowosc {okres in 1..3, elektrownia in 1..2}:
   wygenerowanaEnergia[okres,elektrownia] <= przepustowosc[elektrownia];

subject to ogr_zrzuty_el_1 {okres in 1..3}:
   maximum[1] >= poziomKoncowyWody[okres-1,1] + doplywy[okres,1] - zrzut[okres,1];

subject to ogr_zrzuty_el_2 {okres in 1..3}:
   maximum[2] >= poziomKoncowyWody[okres-1,2] + doplywy[okres,2] + 0.5 * zuzycieWody[okres,1] - zrzut[okres,2] + zrzut[okres,1];
   
subject to ogr_bonus {okres in 1..3}:
   progBonusu * czyBonus[okres] <= sum {elektrownia in 1..2} wygenerowanaEnergia[okres,elektrownia];
   
#metoda punktu odniesienia
subject to ogr_zZysk:
   z <= zZysk;
   
subject to ogr_zPotencjalWytworczy:
   z <= zPotencjalWytworczy;
   
subject to ogr1:
   zZysk <= beta * lambdaZysk * (zysk - zyskCel);
  
subject to ogr2:
   zPotencjalWytworczy <= beta * lambdaPotencjalWytworczy * (potencjalWytworczy - potencjalWytworczyCel);
   
subject to ogr3:
   zZysk <= lambdaZysk * (zysk - zyskCel);
  
subject to ogr4:
   zPotencjalWytworczy <= lambdaPotencjalWytworczy * (potencjalWytworczy - potencjalWytworczyCel);
#/metoda punktu odniesienia

data;
param doplywy:		1		2 :=
             1		200		40
             2		130		15
             3		180		20 ;
param poziomPoczatkowyWody:=      1 1900   2 850    ;
param minimum:=         1 1200   2 800    ;
param maximum:=         1 2000   2 1500   ;
param wydajnosc:=       1 200    2 400    ;
param przepustowosc:=   1 35000  2 60000  ;
param cena := 20;
param wartoscBonusu := 100000;
param progBonusu := 50000;

#metoda punktu odniesienia
param zyskCel := 6000000;
param potencjalWytworczyCel := 3000;
param epsilon := 0.00001;
param beta := 0.001;
param lambdaZysk := 1;
param lambdaPotencjalWytworczy := 1;
#/metoda punktu odniesienia

option solver cplex;
solve;
display zuzycieWody;
display poziomKoncowyWody;
display wygenerowanaEnergia;
display zrzut;
display czyBonus;
display zysk;
display potencjalWytworczy;
