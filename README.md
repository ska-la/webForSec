# Руководство
Данная задача была реализована в ходе курсовой работы методом обратной инженерии. Цель: добавить возможность управления реле замков через интерфейс, отличный от предлагаемого производителем. Веб-интерфейс - идеальное решение для любого мобильного устройства, без привязки приложения к какой-либо конкретной платформе.

---

**Внимание!!!** Данное решение ни коим образом не предназначено для создания обходных путей СКУД. Следует иметь ввиду, что эксплуатация данного ПО без ведома руководства предприятия, тем более в корыстных целях, может стоить Вам рабочего места. Поэтому, настоятельно рекомендуется, поставить в известность начальника IT-подразделения о том, что вы собираетесь сделать или уже сделали.

---

Развёртывание (установка и настройка) потребует определённых знаний и навыков работы в некоторых дополнительных инструментах, таких как сетевой сниффер WireShark и клиент командной строки БД FireBird - isql.exe (isql-fb для Linux). В детали этих инструментов (что,как и почему) мы вдаваться не будем. Будет только пошаговое руководство. Рекомендации: НЕ СТОИТ НИЧЕГО ПЕРЕИМЕНОВЫВАТЬ, ДО ТОГО, КАК ВСЁ ЗАРАБОТАЕТ (кроме того, что рекомендуется). ТАМ ГДЕ ТРЕБУЕТСЯ ВВОД С КЛАВИАТУРЫ - ПРОВЕРЯТЬ НЕСКОЛЬКО РАЗ, т.к. незначительная с виду опечатка может застопорить дело надолго. И вообще, по ходу пьесы, если что-то не так,  прежде чем валить с больной головы на здоровую, желательно остановиться и внимательно поглядеть на собственные руки - всё ли с ними впорядке? Не кривые ли они и оттуда ли растут.. Работоспособность системы была проверена на iPhone, Android и FirefoxOS (собственно проверялось поведение на разных браузерах под разными платформами) - всё работало как и задумывалось изначально.

(ПО - программное обеспечение, БД - база данных)

Итак, приступим.

1. Для простоты (но никак не качества) и скорости был взят IIS7.5 т.к. система ForSec изначально была установлена на Win7 Prof. Т.е. веб-сервер и БД находились на одном компьютере. IIS устанавливается из Панель Управления -> Программы и компоненты -> Включение или отключение компонентов Windows (см. скриншоты).

  <table width="100%"><tr>
  <td align="center"><img src="../../wiki/Add_IIS.jpg" width="90%"></td>
  <td align="center"><img src="../../wiki/Add_IIS_2.jpg" width="90%"></td>
  </tr></table>

2. Далее, поместите СОДЕРЖИМОЕ папки web/ (а НЕ САМУ ПАПКУ !!) в каталог C:\inetpub\wwwroot\ . Для надёжности можно переименовать файл iisstart.htm . Если вы собираетесь подключаться к веб-серверу с другого компьютера или моб. устройства, то надо в фаерволе активировать правило для входящих подключений по HTTP. Для быстрого теста подойдёт и родной IE11.

3. В ПО AccessPoint найдите папку Интеграция и установите из неё подходящий драйвер Firebird ODBC (32/64-bit). Через Панель Управления -> Администрирование -> Источники данных (ODBC) -> Драйверы убедитесь в том, что появился драйвер Firebird/InterBase. В закладке Системный DSN создайте пару подключений к базам данных FireBird: тестовая - employee.fdb и рабочая ForSec - accpoint.gdb . В обоих случаях подойдут параметры "по умолчанию" с пользователем SYSDBA  и его паролем masterkey. Следует только правильно указать расположение файлов баз данных. Воспользуйтесь кнопкой "Проверка соединения". Так же в свойствах самих файлов в закладке Безопасность следует добавить пользователя IIS_WPG с полным набором прав. Собственно employee.fdb нужен только в тестовых целях (как запасной источник данных) и в работе интерфейса участия не принимает.

  <table width="100%"><tr>
  <td align="center"><img src="../../wiki/Add_ODBC_3.jpg" width="90%"></td>
  <td align="center"><img src="../../wiki/Add_ODBC.jpg" width="90%"></td>
  </tr></table>
  <table width="100%"><tr>
  <td width="20%"></td>
  <td align="center"><img src="../../wiki/Add_ODBC_2.jpg"></td>
  </tr></table>

4. Итак, у вас имеются два системных DSN: employee_db и accpoint_db . В каталоге C:\inetpub\wwwroot\ располагаются файлы index.html, fakereq.asp, odoor.asp и папка lib с файлами. Настало время экспериментов. Загляните в текстовый файл cli_odour.sql . Там три строки. Две первые точно такие же (почти) находятся и в файле odoor.asp . Ваша задача сводится к подбору значений, которые подходят для вашей конфигурации. Их не много, но отсюда у вас два пути. Один: использовать WireShark, другой - isql.exe (isql-fb).

5. Что касается WireShark, то в параметрах фильтрации следует указать ip адрес сервера с БД AccessPoint и порт 3050 (FireBird database port). Под Linux пользовались инструментом tcpdump в следующей форме:
  ```
sudo tcpdump -AnnNvv -i1 dst host 192.168.0.1 and port 3050 -w /tmp/AP-snif.tcpdump
```
для уточнения номера интерфейса, на котором нужно слушать (ключ -i), желательно выполнить следующую команду:
  ```
sudo tcpdump -D
```
и, естественно, заменить ip адрес адресом вашего сервера. Перед этим, чтобы исключить ненужный трафик,  следует запустить из Пуск -> AccessPoint -> Монитор и, зарегистрировавшись, выбрать один из планов на котором изображён замок с которым вы собираетесь работать. Желательно выбрать ближайший замок, потому, что при открытии он не будет издавать звукового сигнала (как при прикладывании карточки), а только щёлкать при открытии и закрытии. Вообще, желательно эту работу проводить в конце рабочего дня, когда народ уже разойдётся: и сетевой трафик будет меньше и дверями будут реже пользоваться. Либо, если дверь находится далеко - взять напарника.

  <table width="100%"><tr>
  <td width="30%"></td>
  <td align="center"><img src="../../wiki/Plan_menu.jpg"></td>
  </tr></table>

6. Итак, wireshark или tcpdump заряжены. Монитор запущен. Правой кнопкой мыши щёлкаете на изображении замка (дверная ручка), вызывая контекстное меню, и выбираете "Разблокировать Реле.." . Прислушайтесь и запомните как ведёт себя замок. После того, как анимация замка закончится, останавливаете wireshark/tcpdump и изучаете полученную информацию. Для tcpdump это выглядит так:
  ```
  sudo tcpdump -AnnNvv -r /tmp/AP-snif.tcpdump |less
```
Вас интересует всё, что связано с "INSERT.." . Сравните с тем, что находится в файле cli_odour.sql . Если вам попались ровно два insert'а , ни больше ни меньше, и если они очень похожи на те, что в файле (за исключением нескольких чисел), то, скорее всего, всё в порядке и вы на правильном пути. Если же нет, то дальше мы вам не помощники. Скорее всего у вас или другая версия или вообще что-то иное. Но, можно дочитать, осознать подход и попробовать самому решить задачу. Да, воспользуйтесь Генератором отчётов и в фильтре выставьте только фиолетовые события (Управление устройством и т.д.) в Аппаратных событиях, чтобы ничего лишнего.

7. Используя copy-paste создйте свой файл .sql из ваших insert'ов и добавьте обязательно commit; третьей строкой (не забываем про ";" в конце строк). Теперь **!!!--ВНИМАНИЕ--!!!**: данные команды изменяют содержимое БД, поэтому, если у вас она рабочая и используется для учёта рабочего времени, то обзаведитесь резервной копией (согласно инструкции AccessPoint). НЕ ЭКСПЕРИМЕНТИРУЙТЕ С ДВЕРЯМИ, КОТОРЫЕ СТОЯТ НА ВХОДАХ ПРЕДПРИЯТИЯ. Скорее всего, если ведётся учёт рабочего времени, то именно по ним. Подойдет любая внутренняя дверь.

8. Далее запускаем клиента FIreBird isql.exe (isql-fb):
  ```
  isql.exe -u sysdba -p masterkey
  SQL>connect c:\path\to\accpoint.gdb;
  ...
  SQL>select count(*) from evout;
  ...
  SQL>select count(*) from events where event=127;
  ...
  SQL>input \full\path\to\cli_odour.sql;
  ...
  SQL>select count(*) from evout;
  ...
  SQL>select count(*) from events where event=127;
  ```
  для подключения к удалённой БД используем:
  ```
  SQL>set names UTF-8;
  SQL>connect 192.168.0.1:c:\path\to\accpoint.gdb;
  ```
  при выполнении input'а замок двери может пару раз щёлкнуть, как при использовании карты, без звукового сигнала. Так же, как и при разблокировке реле через Монитор. Если так, то поздравляем вас! Вы почти у цели. Select'ы с count'ами до и после input'а должны при этом выдать разные результаты (после на 1 больше). Снова воспользуйтесь Генератором отчётов: при удачном стечении обстоятельств и расположении звёзд на небе, там прибавится одним событием. Инструкция "set names" нужна только если вы подключаетесь с Linux на windows. Без неё русские буквы не будут отображаться корректно (на Linux у вас должна быть локаль ru_RU.UTF-8).

9. Ну, а дальше только ловкость рук и зоркий глаз. Надо подправить файл odoor.asp . Обратите внимание, что в обоих insert'ах присутствует одинаковое число. В файле cli_odour.sql это "1626", которое соответствует полю POBJECT таблиц EVOUT и EVENTS. У вас оно будет, скорее всего, другим. Этим числом вы и замените в файле odoor.asp наше "1626" (в начале, там где Select Case). **!!!--ВНИМАНИЕ--!!!** Это соответствует в выпадающем списке надписи "на 6 этаже". Не стоит бездумно клацать по другим вариантам, т.к. замки всё равно открываться не будут, а БД будет засоряться ненужным хламом. После того, как вы откроете дверь хоть раз через веб-интерфейс, вы можете всё переделать по своему вкусу, а пока потерпите.

10. В нашем файле cli_odour.sql во втором insert'е обратите внимание на группу чисел "...6,13,5...". Это значения помещаемые в поля PUSER, PCOMPUTER, APPLICATION таблицы EVENTS. В вашем insert'е они, вероятно будут другими. Есть смысл их изменить, чтобы легко можно было дифференцировать эти события, от таких же приходящих от Монитора, в Генераторе отчётов. Чтобы понять на что менять, надо выполнить следующие запросы в клиенте isql :
  ```
  SQL>select id,name from users;
  ...
  SQL>select id,name from comps;
  ...
  SQL>(не могу пока вспомнить в какой таблице можно посмотреть приложения)
```
и выбрать подходящий ID. Можно просто добавить нового пользователя через Конфигуратор, что-то вроде "Браузер" (с паролем или без - неважно) и использовать его ID в вашем insert'е. 

11. Тут мы плавно перешли ко второму пути о котором упоминали в конце пункта 4. Этот путь действителен только при условии, что у вас ForSec AccessPoint версии 1.1.10 . И мы предполагаем что структура баз у нас с вами идентичная. Итак, значения для полей PUSER, PCOMPUTER и APPLICATION таблицы EVENTS мы можем определить select'ами из пункта 10. Теперь что касается поля POBJECT, выполняем следующую команду:
  ```
  SQL>select pobject from pobjects where pobjecttype=98;
```
и получаем список чисел. Прикиньте, соответствует ли количество чисел количеству дверей без учёта вертушек на проходной. Тут существует определённая сложность: какое число соответствует вашей двери. Решите это, выполнив команду:
  ```
  SQL>select id,name from pdevices where dtype=3;
```
тут уж точно можно собрать полный комплект ID'ишников для реле всех дверей. Используя полученные значения, надо выполнить шаги 7-9.

12. Теперь, когда тест через клиента isql.exe|isql-fb прошёл успешно и файл odoor.asp подкорректирован, идём дальше. Через Панель Управления -> Администрирование -> Диспетчер служб IIS запускаем веб-сервер. Далее все сообщения от этого сервера можно прочесть в логах по адресу C:\inetpub\logs\LogFiles\W3SVC1 . Замечание: у нас запись шла с задержкой в 2 минуты - мрак! В браузере (либо на сервере, либо на моб.устройсте, либо на вашем рабочем компьютере) наберите ip адрес сервера - должна отобразиться стартовая страница с кнопкой "Где?". После нажатия на неё должен вывалиться список этажей. Вам нужен пункт "на 6 этаже", если вы ничего больше не меняли в дизайне страницы. **!!!--ВНИМАНИЕ--!!!** При первом нажатии на кнопку "Где?" появится сообщение об ошибке. Нажмите "ОК", что "да, я в курсе ошибки". Похоже, что это косяк драйвера или операционки - первоое подключение IIS к БД проходит с ошибкой. Может быть, не хватает параметров именно для первого запроса, но факт остаётся фактом: все остальные запросы проходят без проблем. Для этого и существует файл fakereq.asp, который и выполняется первым при нажатии на "Где?". Он пытается получить из БД текущее время, но завершается с ошибкой. Так сказать "жертвует собой, чтобы остальным было хорошо".

---
Вот, вроде бы и всё. Кажется, ничего не упущено. Если что, [пишите] (mailto:akdotvokchusatgmaildotcom), спрашивайте. Чем сможем - поможем. Да! Если найдутся желающие написать и поделиться с другими скриптами реализующими эту же функцию на Perl или PHP, то милости просим - разместим ваш код здесь же.

Вообще, целесообразность использования данного интерфейса на постоянной основе, крайне сомнительна. Но, может служить отправной точкой для создания более гибкого интерфейса для системы вцелом. Понятно, что производителю ForSec'а это не выгодно, т.к. они берут деньги за количество рабочих мест. А с веб-сервером, это будет уже сложнее отслеживать.
