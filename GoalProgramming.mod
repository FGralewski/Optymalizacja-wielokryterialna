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

#programowanie celowe
param zyskWagaPlus;
param zyskWagaMinus;
param zyskCel;
param potencjalWytworczyWagaPlus;
param potencjalWytworczyWagaMinus;
param potencjalWytworczyCel;
#/programowanie celowe

#zmienne
var zuzycieWody {1..3,1..2} >= 0;
var wygenerowanaEnergia {1..3,1..2} >= 0;
var poziomKoncowyWody {0..3,1..2} >= 0;
var zrzut {1..3,1..2} >=0;
var czyBonus {1..3} binary;

#programowanie celowe
var zyskPlus >=0;
var zyskMinus >=0;
var potencjalWytworczyPlus >=0;
var potencjalWytworczyMinus >=0;
var zysk = sum {okres in 1..3, elektrownia in 1..2} cena * wygenerowanaEnergia[okres,elektrownia] 
   + sum {okres in 1..3} czyBonus[okres] * wartoscBonusu
   - zyskPlus
   + zyskMinus;
var potencjalWytworczy = sum {elektrownia in 1..2} poziomKoncowyWody[3,elektrownia]
   - potencjalWytworczyPlus
   + potencjalWytworczyMinus;
#/programowanie celowe

#funkcja celu
minimize cel: zyskWagaPlus * zyskPlus
              + zyskWagaMinus * zyskMinus
              + potencjalWytworczyWagaPlus * potencjalWytworczyPlus
              + potencjalWytworczyWagaMinus * potencjalWytworczyMinus;

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
   
#programowanie celowe
subject to ogr_zysk:
   zysk = zyskCel;
   
subject to ogr_potencjalWytworczy:
   potencjalWytworczy = potencjalWytworczyCel;
#/programowanie celowe

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

#programowanie celowe
param zyskWagaPlus := 0.0001;
param zyskWagaMinus := 1;
param zyskCel := 500000;
param potencjalWytworczyWagaPlus := 0.0001;
param potencjalWytworczyWagaMinus := 1;
param potencjalWytworczyCel := 1000;
#/programowanie celowe

option solver cplex;
solve;
display zuzycieWody;
display poziomKoncowyWody;
display wygenerowanaEnergia;
display zrzut;
display czyBonus;
display zysk;
display zyskPlus;
display zyskMinus;
display potencjalWytworczy;
display potencjalWytworczyPlus;
display potencjalWytworczyMinus;
