program Last;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Generics.Defaults,
  Generics.Collections;

Type

   // Тип данных, представляющий анонимную процедуру с параметром it.
  TAppliedProc = reference to procedure(it:integer);
  {TList расширяется методом Each, параметром для которого является
  анонимная процедура Proc, применяемая ко всем элементам списка.}
  LList<T> = class (TList<T>)
    procedure Each(proc:TAppliedProc);
  end;

  Mass=array of integer;
  Models= record
    NameModel: string;
    TypeModel:byte;
  end;

  TD=record
    number:STRING[11];
    name: string[40];
    datecall:array of string;
  end;

  TPhone=class
    Private
      FModel:Models;
      FTD:array of TD;  //Telephone directory
    Public
      procedure SetFModel(a:Models);//устанавливать
      function GetFModel: Models;
      Procedure CallContakt();//Дату звонка добавила в запись как массив
      Procedure MailS();virtual;//отправка смс на номер смс
      procedure HistoryTD(name:string;number:string);virtual;
      procedure PrintModel;
      procedure PrintFTD;  //вывод телефонной книги
      property Model:Models
        read GetFModel //получать
        write SetFModel;
  end;

  TSmartPhone= class(TPhone)
  Private
    FMail: array of string;//дата отправки смс
  Public
    Procedure MailS();override;//отправка смс на номер смс
    Procedure HistoryTD(name:string;number:string);override;
  end;

  TGreatPhone=class
    private
      FMP:TList<TPhone>;
    public
      procedure Each(proc:TAppliedProc);
      Procedure Add(Var f:TextFile);
      Procedure AddTD(n:string);
      Procedure PrintAllModel();
      Procedure PrintTD(n:string);
      Procedure Call(n:string);
      Procedure Mail(n:string);
      Procedure Search(Var a:Mass;number:string;name:string);
      Procedure History(name:string;number:string);
      Procedure Clear(n:string);
  End;

////////////////////////////////////////////////////////////////////////////////
  Procedure TGreatPhone.Add(Var f:TextFile);
  Var Phone:TPhone;
      SmartPhone:TSmartPhone;
      m:Models;
      flag:boolean;
      a:string;
      k,i:integer;
   Begin
   flag:=true;
   a:='';
   Writeln('Choose what phone at you will be. 1- Phone, 2-SmartPhone.');
   Readln(m.TypeModel);
   While flag or EOF(f) do
     Begin
       Readln(f,a);
       If a<>'' then
       Begin
         m.NameModel:=a;
         flag:=false;
       end;
     End;
   If m.TypeModel=1
     then
       Begin
         Phone:=TPhone.Create;
         Phone.Model:=m;
         FMP.Add(Phone);
       End
       Else
         If m.TypeModel=2
           then
             Begin
               SmartPhone:=TSmartPhone.Create;
               SmartPhone.Model:=m;
               FMP.Add(SmartPhone);
             End;
  end;

  Procedure TGreatPhone.PrintAllModel();
  Var i:integer;
  Begin
  Writeln('Model and unique identification number of phone');
  for i:=0 to FMP.Count-1 do
      TPhone(FMP[i]).PrintModel;
  end;

 Procedure TGreatPhone.AddTD(n:string);
  Var flag:boolean;
      i,k:integer;
      cont:TD;
      SmartPhone:TSmartPhone;
      Phone:TPhone;
  Begin
  If FMP.Count=0
    Then
      Begin
        Writeln('For addition of contact in the telephone directory, you need to add phone model');
        exit;
      End;
  flag:=false;
  For i:=0 to (FMP.Count-1) do
    If n=TPhone(FMP[i]).FModel.NameModel
      then
        Begin
          flag:=true;
          k:=i;
        end;
  If not(flag)
    Then
      Begin
        Writeln('Data have been entered incorrectly, there is no such model in the list');
        exit;
      end;
  Writeln('Enter a contact name');
  Readln(cont.name);
  n:='';
  While (length(n)<>11) or (n[1]<>'8') do
    begin
      Writeln('Enter a phone number (11 figures, since 8)');
      Readln(n);
      If (length(n)<>11) or (n[1]<>'8')
        Then
          Writeln('There was a mistake, number has been entered incorrectly! Enter number correctly.');
    end;
  cont.number:=n;
  If TPhone(FMP[k]).FModel.TypeModel=1
      then
        Begin
          Phone:=TPhone.Create;
          Phone:=TPhone(FMP[k]);
          SetLength(Phone.FTD,Length(Phone.FTD)+1);
          Phone.FTD[Length(Phone.FTD)-1]:=cont;
          FMP[k]:=Phone;
        end;
  If TPhone(FMP[k]).FModel.TypeModel=2
      then
        Begin
          SmartPhone:=TSmartPhone.Create;
          SmartPhone:=TSmartPhone(FMP[k]);
          SetLength(SmartPhone.FTD,Length(SmartPhone.FTD)+1);
          SmartPhone.FTD[Length(SmartPhone.FTD)-1]:=cont;
          FMP[k]:=SmartPhone;
        end;
  end;

  Procedure TGreatPhone.PrintTD(n:string);
  Var i,k:integer;
      flag:boolean;
  Begin
  If FMP.Count=0
    Then
      Begin
        Writeln('For addition of contact in the telephone directory, you need to add phone model');
        exit;
      End;
  flag:=false;
  For i:=0 to (FMP.Count-1) do
    If n=TPhone(FMP[i]).FModel.NameModel
      then
        Begin
          flag:=true;
          k:=i;
        end;
  If not(flag)
    Then
      Begin
        Writeln('Data have been entered incorrectly, there is no such model in the list');//Данные были введены неверно, такой модели нет в списке
        exit;
      end;
      TPhone(FMP[k]).PrintFTD;
  end;

  Procedure TGreatPhone.Call(n:string);  //Работаю с этим
  Var i,k:integer;
      flag:boolean;
      Phone:TPhone;
      SmartPhone:TSmartPhone;
  Begin
  If FMP.Count=0
    Then
      Begin
        Writeln('For addition of contact in the telephone directory, you need to add phone model');
        exit;
      End;
  flag:=false;
  For i:=0 to FMP.Count-1 do
    If n=TPhone(FMP[i]).FModel.NameModel
      then
        Begin
          flag:=true;
          k:=i;
        end;
  If not(flag)
    Then
      Begin
        Writeln('Data have been entered incorrectly, there is no such model in the list');//Данные были введены неверно, такой модели нет в списке
        exit;
      end;
  If TPhone(FMP[k]).FModel.TypeModel=1
      then
        Begin
          TPhone(FMP[k]).CallContakt;
          FMP[k]:=Phone;
        end;
  If TPhone(FMP[k]).FModel.TypeModel=2
      then
        Begin
          TSmartPhone(FMP[k]).CallContakt;
          FMP[k]:=SmartPhone;
        end;
  end;

  Procedure TGreatPhone.Mail;
  Var i,k:integer;
      flag:boolean;
      SmartPhone:TSmartPhone;
  begin
  If FMP.Count=0
    Then
      Begin
        Writeln('For addition of contact in the telephone directory, you need to add phone model');
        exit;
      End;
  flag:=false;
  For i:=0 to FMP.Count-1 do
    If n=TPhone(FMP[i]).FModel.NameModel
      then
        Begin
          flag:=true;
          k:=i;
        end;
  If not(flag)
    Then
      Begin
        Writeln('Data have been entered incorrectly, there is no such model in the list');//Данные были введены неверно, такой модели нет в списке
        exit;
      end;
  If TPhone(FMP[k]).FModel.TypeModel=1
    Then
      Begin
        Writeln('This function is not available to model of this phone');
        exit;
      End;
  if TSmartPhone(FMP[k]).FModel.TypeModel=2
    Then
      Begin
        SmartPhone:=TSmartPhone(FMP[k]);
        SmartPhone.MailS();
        FMP[k]:=SmartPhone;
      End;
  end;

  Procedure TGreatPhone.Search(Var a:Mass;number:string;name:string) ; //ОШИБКА!!!!!!!!ДОДЕЛАТЬ!!!!
    Var i,j:integer;
        flag:boolean;
  Begin
    flag:=false;
    for I := 0 to  FMP.Count- 1 do
      Begin
        for J := 0 to (Length(TPhone(FMP[i]).FTD) - 1) do
        Begin
         If (name=TPhone(FMP[i]).FTD[j].name) and (TPhone(FMP[i]).FTD[j].number=number)
         Then
           Begin
            flag:=true;
            SetLength(a,Length(a)+1);
            a[length(a)-1]:=i;
           End
         Else
           flag:=false;
        End;
      End;
  end;

  Procedure TGreatPhone.History(name:string;number:string);
    Var a:Mass;
        I:Integer;
        SmartPhone:TSmartPhone;
  begin
    Search(a,number,name);
    Writeln('History:');
    For I := 0 to length(a) - 1 do
      Begin
        TSmartPhone(FMP[a[i]]).HistoryTD(name,number);
        if TSmartPhone(FMP[a[i]]).FModel.TypeModel=2
          Then
            Begin
              TSmartPhone(FMP[a[i]]).HistoryTD(name,number);
            End;
      End;
  end;

  procedure TGreatPhone.Each(Proc: TAppliedProc);
  var it: Integer;
  begin
    for it := 0 to High(Self)-1 do
      Proc(it);
  end;

  {Procedure TGreatPhone.Clear(n: string);
  Var flag:boolean;
      k,i:integer;
  Begin
    flag:=false;
    For i:=0 to FMP.Count-1 do
      If n=TPhone(FMP[i]).FModel.NameModel
        Then
          Begin
            flag:=true;
            k:=i;
          end;
    If not(flag)
      Then
        exit;
    FMP.Delete(k);
  End;      }
  ////////////////////////////////////////////////////////////////////////////////

  Procedure TPhone.SetFModel(a:Models);
  Begin
    FModel:=a;
  End;

  Function TPhone.GetFModel:Models;
  Begin
    Result:=FModel;
  End;

  Procedure TPhone.PrintModel;
  Begin
    If Length(FModel.NameModel)=0
      Then
        Begin
          Writeln('Sorry, but the model of phone has not been added!');
          exit;
        End;
    Writeln(FModel.NameModel,' ',FModel.TypeModel);
  End;

  Procedure TPhone.PrintFTD;
    Var i:integer;
  Begin
    If Length(FTD)=0
      Then
        Begin
        Writeln('Sorry, but telephone directory empty!');
        exit;
        End
      Else
        Begin
          Write('Name':20);
          Writeln('Number':20);
          For i:=0 to (Length(FTD)-1) do
            Begin
              Write(i+1,': ',FTD[i].name:20);
              Writeln(FTD[i].number:20);
            End;
        End;
  End;

  Procedure TPhone.CallContakt();
     Var I:integer;
         name,number:STRING;
         flag:boolean;
  Begin
    If Length(FTD)=0
      Then
        exit;
     Writeln('Enter a contact name');
     Readln(name);
     Writeln('Enter a contact phone number.');
     Readln(number);
     For i:=0 to (length(FTD)-1) do
       Begin
         If (name=FTD[I].name) and (FTD[I].number=number)
         Then
           Begin
            Setlength(FTD[I].datecall,LENGTH(FTD[I].datecall)+1);
            FTD[I].datecall[length(FTD[I].datecall)-1]:=DatetimeToStr(Now);
            Writeln('Thanks for a call! We will call back to you tomorrow!');
            flag:=true;
            EXIT;
           End
         Else
           flag:=false;
       end;
     IF flag=false THEN WRITELN('THERE IS NO THIS CONTACT IN THE TELEPHONE DIRECTORY OR DATA HAVE BEEN ENTERED INCORRECTLY!');
  end;

  Procedure TPhone.MailS();
  Begin
  end;

  Procedure TSmartPhone.MailS();
    Var i:integer;
        name,number,str:STRING;
        flag:boolean;
        Dat:TDateTime;
  Begin
  If Length(FTD)=0
    Then
      exit;
  Writeln('Enter a contact name');
  Readln(name);
  Writeln('Enter a contact phone number.');
  Readln(number);
  For i:=0 to (length(FTD)-1) do
    Begin
      If (name=FTD[I].name) and (FTD[I].number=number)
        Then
          Begin
            Setlength(FMail,LENGTH(FTD));
            Writeln('Enter the text of the message');//Введите текст сообщения
            Readln(str);
            FMail[I]:=DateTimeToStr(Now)+' '+str;
            flag:=true;
            EXIT;
          End
        Else
          flag:=false;
    end;
  IF flag=false THEN WRITELN('THERE IS NO THIS CONTACT IN THE TELEPHONE DIRECTORY OR DATA HAVE BEEN ENTERED INCORRECTLY!');
  end;

  Procedure TPhone.HistoryTD(name:string;number:string);
  Var I,J:integer;
      flag:boolean;
  Begin
     If  Length(FTD[i].datecall)=0
       then
         exit;
     for I := 0 to (Length(FTD) - 1) do
      Begin
        If (name=FTD[i].name) and (FTD[i].number=number)
          Then
            Begin
              for J := 0 to (Length(FTD[i].datecall) - 1) do
                Writeln(FTD[i].datecall[J]);
            End;
      End;
  end;

  Procedure TSmartPhone.HistoryTD(name:string;number:string);
  Var I,J:integer;
      flag:boolean;
  Begin
    Inherited  HistoryTD(name,number);
    If Length(FMail)=0
      then
        exit;
    for I := 0 to (Length(FTD) - 1) do
      Begin
        If (name=FTD[i].name) and (FTD[i].number=number)
          Then
                Writeln(FMail[i]);
      End;
  end;

  Procedure MyMenu(GreatPhone:TGreatPhone);
  Var punkt:byte;
      n,name,number:string;
      f:TextFile;
      a:Mass;
      I: integer;
      Phone:TPhone;
  Begin
    Assign(f,'Model.txt');
    Reset(f);
    GreatPhone.FMP := TList<TPhone>.Create;
    repeat
    writeln('Menu:');
    writeln('0. Exit');
    writeln('1. To add phone model');
    writeln('2. To add number to the telephone directory');
    writeln('3. To call');
    writeln('4. To send SMS');
    writeln('5. History of calls');
    writeln('6. Phone models');
    writeln('7. Telephone directory');
    Writeln('8. Contact search');
    Writeln('9. Clear Model Phone');//Удаление модели телефона
    writeln('What do you want to make?');
    readln(punkt);
    case punkt of
      0: writeln('Goodbye!');
      1:GreatPhone.Add(f);
      2:
        begin
          Writeln('Enter the name of brand of phone.');
          Readln(n);
          GreatPhone.AddTD(n);
        end;
      3:
        begin
          Writeln('Enter the name of brand of phone.');
          Readln(n);
          GreatPhone.Call(n);
        end;
      4:
        Begin
          Writeln('Enter the name of brand of phone.');
          Readln(n);
          GreatPhone.Mail(n);
        end;
      5:
        Begin
          Writeln('Enter a contact name');
          Readln(name);
          Writeln('Enter a contact phone number.');
          Readln(number);
          GreatPhone.History(name,number);
        End;
      6: GreatPhone.PrintAllModel();
      7:
        begin
          Writeln('Enter the name of brand of phone.');
          Readln(n);
          GreatPhone.PrintTD(n);
        end;
      8:
        begin
          Writeln('Enter a contact name');
          Readln(name);
          Writeln('Enter a contact phone number.');
          Readln(number);
          GreatPhone.Search(a,number,name);
          If Length(a)<>0
            Then
              Begin
                Writeln('This contact contains in telephone directories:');
                for I := 0 to Length(a) - 1 do
                   Writeln(TPhone(GreatPhone.FMP[a[i]]).FModel.NameModel);
              End
            Else
              Writeln('This contact does not contain in one telephone directory');
          Setlength(a,0);
        end;
      9:
        Begin
          Writeln('Enter the name of brand of phone.');
          Readln(n);
          TGreatPhone.each(procedure (it:integer)
                begin
                  if n=TPhone(GreatPhone.FMP[it]).FModel.NameModel
                    then
                      GreatPhone.FMP.Delete(it);
                end);
          GreatPhone.Clear(n);
        End;
    end;
  until punkt = 0;
  Close(f);
  End;

  Var GreatPhone:TGreatPhone;
Begin
  GreatPhone:=TGreatPhone.Create;
  MyMenu(GreatPhone);
end.
