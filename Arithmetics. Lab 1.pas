{
	Программа преобразует числа из файлов "number1.txt","number2.txt" в двумерный массив.
	Результаты вычислений записывает в файлы Sum.txt и Sub.txt.
}

program lab1;

const n = 50;	//n-мерный массив

type  Tlong = array [1..2,1..n] of byte; //Tlong - это тип массива, для целочисленной арифметики нужен двумерный

var Fnumb : text;	//ассоциируем с файлом
	Error : boolean;//индикатор ошибок
	Anumb : Tlong;	//массив, в первой ячейке разрядность числа, далее - само число поразрядно в перевернутом виде
	Bnumb : Tlong;	//второе такое число
	equal : boolean;//True если числа равны
	Cnumb : Tlong;	//результирующее суммы
	Dnumb : Tlong;	//разультурующее разности

	rstr:string;//для проверки

procedure Read_TLong(var f : text; var mas : Tlong; var Err : boolean); //считывает из файла в массив
	var i,  index: integer; //индикаторы
		point: integer;	//хранит позицию точки
		ValErr : integer; //индикатр ошибок в val
		rstring,fstring : string; //для целой и дробной частей

	begin
		read(f,rstring); //считывание числа в строковую переменную
		close(f);

		ValErr := 0; //обнуление индикаторов ошибок
		Err := false;

		rstring := Trim(rstring); //убираем лишние пробелы по бокам
		writeln('Входные данные');
		writeln(rstring); // для удобной проверки

		if rstring.Length div 2 + 1 < n then //разбитое на разряды число должно вместится в n-мерный массив
		begin
			point := pos('.',rstring);	//хранит место точки
			if rstring.IndexOf('.') > 0 then
				if pos('.',rstring.Remove(rstring.IndexOf('.'),1)) > 0 then //если есть точка и только одна, значит нужно выделить дробную часть
				begin
					writeln('Лишние точки. Ошибка!');
					Err := true;
				end
				else //ошибки нет, работаем с дробной частью
				begin
					fstring := copy(rstring, point + 1, length(rstring) - point); //формируем строку с дробной частью
					delete(rstring, point, length(rstring) - point + 1);	//удаляем дробную часть и оставляем целую
					if fstring.length mod 2 = 0 then
						mas[2,1] := fstring.length div 2 //запишем разрядность др части в 1 эл мас
					else
					begin
						mas[2,1] := fstring.length div 2 + 1;//если нечетное кол-во цифр
						fstring := fstring + '0';	//добавим "0" в конец
					end;
					index := 1;	//с этой позиции копируется по два символа в массив
					i:=2;
					while (index <= fstring.length) and (Err = false) do //двигаемся влево с конца строки по два символа
					begin
						val(copy(fstring, index, 2), mas[2,i], ValErr);	//преобразуем в число и записываем в массив
						if ValErr <> 0 then	//при ошибке перевода
						begin
							Err := true;
							writeln('Произошла ошибка при переводе строки в число');
						end;
						index+=2;
						inc(i);
					end;
				end;

			if Err = false then // если ошибок не было, то работаем с целой частью
			begin
				if rstring.length mod 2 = 0 then {если четное кол-во эл, то не нужно дополнять нулем}
					mas[1,1] := rstring.length div 2	{записываем разрядность в первый эл массива}
				else
				begin
					mas[1,1] := rstring.length div 2 + 1;{при нечетном нужно дополнить нулем}
					rstring := '0' + rstring;{дополняем 0}
				end;
				index := rstring.length - 1;{позиция, с которой копируется по два символа из строки}
				i := 2;{тк начнем запись во вторую ячейку. в первой - разрядность числа.}
				While (index >= 0) and (Err = false) do
				begin
					val(copy(rstring,index,2),mas[1,i],ValErr);{копируем два символа с конца, переводим в число, заносим в массив}
					if ValErr <> 0 then{при ошибке перевода}
					begin
						Err := true;
						writeln('Произошла ошибка при переводе строки в число');
					end;
					index-=2;{индекс, с которого копируем строчные символы для перевода в число}
					inc(i);{номер следующей ячейки в массиве}
				end;
			end;

			//для удобной проверки
			write('[целая] = ':12);
			for i:=1 to mas[1,1]+1 do
				write('[',mas[1,i],']');
			writeln;
			write('[дробная] = ':12);
			for i := 1 to mas[2,1]+1 do
				write('[',mas[2,i],']');
			writeln;
			writeln;
			//для удобной проверки

		end
		else
			begin
				writeln('выход за границы массива, нужно увеличить кол-во элементов в массиве (увеличь n!)');
				Err := true;
			end;
	end;

procedure Write_TLong (var f : text; var mas : Tlong); //процедура вывода
	var i : Integer;

	begin
		Rewrite(f);
		for i := mas[1,1] downto 2 do //вывод целой части в файл
		begin
			if (mas[1,i] < 10) and (i<>mas[1,1]) then //добавим 0, если элемент массива <10
				write(f,'0',IntToStr(mas[1,i]))
			else
				write(f,IntToStr(mas[1,i])); //преобразуем в стринг и пишем в файл
		end;
		if mas[2,1] <> 0 then //if we have real part then...
		begin
			write(f,'.'); //...add point
			for i:=2 to mas[2,1]+1 do //вывод дробной части в файл
			begin
				if (mas[2,i] < 10)  then //дополнение нулем 
					write(f,'0',IntToStr(mas[2,i]))
				else
					if (mas[2,i] > 1) and (mas[2,i] mod 10 = 0) and (i = mas[2,1]+1) then
						write(f,mas[2,i] div 10)
					else
						write(f,IntToStr(mas[2,i]));
			end;
		end;
		close(f);

	end;

function LessOrEq(A,B : Tlong; var Eq : boolean) : boolean; //Сравнение. Если А>B, то true, иначе false. Если Eq = true, то А = В
	var i:integer;

	begin //сначала проверка по целой части
		Eq := false;
		if A[1,1] <> B[1,1] then //сравниваем ранги
			if A[1,1] > B[1,1] then
				LessOrEq := true //A>B по рангу
			else
				LessOrEq := false //A<B по рангу
		else //если ранги равны, то сравним элементы массивов
		begin
			i := A[1,1] + 1; //последний эл массива
			while (i > 0) and (A[1,i] = B[1,i]) do //сравниваем с конца. если все эл равны, то дойдем до начала
				dec(i);
			if i > 1 then //если не дошли до начала массива, значит остановились на неравных элементах
				if A[1,i] > B[1,i] then
					LessOrEq := true
				else
					LessOrEq := false
			else //сравнение дробной части
			begin
			i:=2;
				while (i < (A[2,1]+1)) and (A[2,i] = B[2,i]) do //здесь какая-то дичь, но я это сделал
					inc(i);
				if A[2,i] <> B[2,i] then
					if A[2,i] > B[2,i] then
						LessOrEq := true
					else
						LessOrEq := false
				else
				begin
					Eq := true; //дробные части равны!
				end;
			end; 
		end;
	end;

procedure Sum_TLong(A,B : TLong; var C : TLong);
 var 	i 	: integer;

	begin

		//сложение дробных частей

		if (A[2,1] > 0) or (B[2,1] > 0) then //при существовании дробной части
		begin
			if A[2,1] >= B[2,1] then //чтобы складывать с последнего элемента, выберем больший ранг
				i := A[2,1] + 1
			else
				i := B[2,1] + 1;
			while i > 1 do //пока не дошли по первого элемента массива - суммируем
			begin
				if (C[2,i] + A[2,i] + B[2,i] >= 100) then //если нужно перенести разряд
				begin
					C[2,i] += A[2,i] + B[2,i] - 100;
					if i-2 > 0 then	//если нужно перенести разряд из дробной части в целую
						C[2,i-1] += 1
					else
					begin
						C[1,2] += 1; //переносим разряд
						C[1,1] += 1; //объявляем кол-во разрядов
					end;
					C[2,1] := i; //разряды
				end
				else
				begin
					C[2,i] += A[2,i] + B[2,i];
					inc(C[2,1]);		
				end;
				dec(i);
			end;
		end;

		//сложение целых частей

		i:=2; //складываем массивы со второго элемента
		while (i <= A[1,1] + 1) or (i <= B[1,1] + 1) do //перебор с последнего эл до первого
		begin
			C[1,i] += A[1,i] + B[1,i]; //складываем целые части
			if (C[1,i]) < 100 then 	// если не нужно переносить разряд, то
				C[1,1] := i 		//запишем кол-во разрядов
			else //если нужно перенести разряд
			begin
				C[1,i] -= 100; //корректируем значение при перенесении разряда
				if (A[1,i+1] = 0) and (A[1,1] < (i+1)) then //если нужно перенести разряд
				begin
					A[1,1] += 1; 	//добавляем разярд
					A[1,i+1] += 1; 	//переносим десяток, сотню и тд
					C[1,1] := i; 	//запишем окончательное кол-во разрядов
				end
				else
				begin
					A[1,i+1] += 1;	//или просто переносим десяток, сотню и тд
					C[1,1] := i; 	//запишем окончательное кол-во разрядов
				end;
			end;
			inc(i);//делаем шаг
		end;

		//удобненькая проверка
		writeln('C  (результирующая сложения)');
		write('[целая] = ':12);
		for i:=1 to C[1,1]+1 do
			write('[',C[1,i],']');
		writeln;
		write('[дробная] = ':12);
		for i := 1 to C[2,1]+1 do
			write('[',C[2,i],']');
		writeln;
		writeln;
		//удобненькая проверка

	end;

procedure Sub_Tlong(A,B : TLong; var D : TLong; compare : boolean);
	var i,j : integer;

	begin
		//дробная часть

		if (A[2,1]>0) or (B[2,1]>0) then //если присутствует дробная часть
		begin
			if A[2,1]>B[2,1] then //найдем максимальное количество разрядов
				i:=A[2,1]+1
			else
				i:=B[2,1]+1;
			while i>1 do
			begin
				if A[2,i]>=B[2,i] then
				begin
					D[2,i] += A[2,i] - B[2,i];
					inc(D[2,1]);		
				end
				else
				begin
					j:=i-1;
					while (A[2,j] = 0) and (j > 1) do
					begin
						A[2,j] += 99;
						dec(j);
					end;
					if j = 1 then
					begin
						j := 2;
						while A[1,j]=0 do //поиск эл из которого можно взять разряд
						begin
							A[1,j] += 99; //попутно "распихиваем" остатки разряда, который найдется
							inc(j);
						end;
						dec(A[1,j]); //отняли разряд
					end
					else
						dec(A[2,j]);
					D[2,i] +=A[2,i] + 100 - B[2,i];
					inc(D[2,1]);
				end;
				dec(i);
			end;
		end;

		//целая часть
		i:=2;
		var flag := false;
		while (i <= A[1,1] + 1) do
		begin
			if A[1,i]<B[1,i] then
			begin
				j:=i+1;
				while A[1,j]=0 do //поиск эл из которого можно взять разряд
				begin
					A[1,j] += 99; //попутно "распихиваем" остатки разряда, который найдется
					inc(j);
				end;
				dec(A[1,j]); //отняли разряд
				D[1,i] := (A[1,i] + 100) - B[1,i];
			end
			else
				D[1,i] := A[1,i] - B[1,i];
			D[1,1] := i;
		inc(i);
		end;

		i:=2;
		while D[1,i] = 0 do //нужно убрать лишние нули из начала целого числа
		begin
			dec(D[1,1]);
			inc(i);
		end;

		//для удобной проверки
		writeln('D  (результирующая разности)');
		write('[целая] = ':12);
		for i:=1 to D[1,1]+1 do
			write('[',D[1,i],']');
		writeln;
		write('[дробная] = ':12);
		for i := 1 to D[2,1]+1 do
			write('[',D[2,i],']');
		writeln;
		writeln;
		//для удобной проверки

	end;

Begin 
	if (FileExists('number1.txt') = true) and (FileExists('number2.txt') = true) and (FileExists('Sum.txt') = true) and (FileExists('Sub.txt')) then{Проверка на сущ файла}
	begin
		Assign(Fnumb, 'number1.txt'); //работа с первым файлом
		Reset(Fnumb);
		Read_TLong(Fnumb, Anumb, Error); //Процедура считывания в массив
		Assign(Fnumb, 'number2.txt'); //работа со вторым файлом
		if Error=false then 
		begin
			Reset(Fnumb);
			Read_Tlong(Fnumb, Bnumb, Error);
			if Error = false then 
			begin
				Sum_TLong(Anumb, Bnumb, Cnumb);	//суммируем
				Assign(Fnumb,'Sum.txt');
				Write_TLong (Fnumb,Cnumb);

				//разность
				equal := false; //обнуляй
				if (LessOrEq(Anumb, Bnumb, equal) = true) or (equal = true) then //нужно от большено отнимать меньшее
					Sub_Tlong(Anumb, Bnumb, Dnumb, LessOrEq(Anumb, Bnumb, equal)) //разность без рокировки
				else
					Sub_Tlong(Bnumb, Anumb, Dnumb, LessOrEq(Anumb, Bnumb, equal)); //разность с рокировкой
				Assign(Fnumb,'Sub.txt');
				Write_TLong (Fnumb,Dnumb);
			end
			else 
				writeln('ошибка при работе со вторым файлом');
		end
		else
			writeln('ошибка при работе с первым файлом');
	end
	else writeln('Один из файлов не существует');

	//удобный вывод результатов
	if Error = false then
	begin
		writeln;
		assign(Fnumb, 'Sum.txt');
		reset(Fnumb);
		read(Fnumb,rstr);
		if rstr.length = 0 then
			writeln('Sum.txt = ПУСТО')
		else
			writeln('number 3 = ',rstr);
		close(Fnumb);

		writeln;
		assign(Fnumb, 'Sub.txt');
		reset(Fnumb);
		read(Fnumb,rstr);
		if rstr.length = 0 then
			writeln('Sub.txt = ПУСТО')
		else
			writeln('Sub.txt = ',rstr);
		close(Fnumb);
	end;

End.