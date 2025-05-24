# Another Survivor
## Назначение проекта
Продемонстрировать свои навыки в Godot.<br/>

В качестве примера мной выбрана игра типа "Vampire Survivors". На текущий момент проект не более чем демо. Планирую улучшать и расширять функционал.
## Реализованный функционал
### Меню
Главное меню с опциями, загрузкой сохраненной игровой сессии, началом новой сесии, выбором уровня. Игровое меню.<br/>
<picture>
 <img width="200px" src="https://github.com/KonstantinZsky/Another-Survivor/blob/main/Readme%20pics/main_menu.png" alt="qr"/>
</picture>
<picture>
 <img width="400px" src="https://github.com/KonstantinZsky/Another-Survivor/blob/main/Readme%20pics/options_menu.png" alt="qr"/>
</picture>
<picture>
 <img width="400px" src="https://github.com/KonstantinZsky/Another-Survivor/blob/main/Readme%20pics/level_menu.png" alt="qr"/>
</picture><br/>
### Локализация
В опциях можно выбрать между русским и английским языком. Все элементы интерфейса будут переведены, реализовано при помощи **gettext**.
### Система загрузки и сохранений
В любой момент игровую сессию можно сохранить, чтобы впоследствии загрузить из главного меню или игрового меню. У сохранения есть имя, время, размер игрового поля в пикселях, номер уровня, которые видны в списке сохранений. Так же делается скриншот миникарты, который отображается при выборе сохранения. Реализовано при помощи **Resource** файлов.<br/>
<picture>
 <img width="600px" src="https://github.com/KonstantinZsky/Another-Survivor/blob/main/Readme%20pics/save_menu.png" alt="qr"/>
</picture>
### Миникарта
В играх типа "Vampire Survivors" миникарты обычно нет, но зато она есть в огромном количестве других игр, поэтому я ее реализовал.
В режиме паузы можно двигать камеру (в том числе мышкой по миникарте), рамка камеры отображается на миникарте как и противники и игрок. Так же отображаются пропорции игрового поля.<br/>
<picture>
 <img width="600px" src="https://github.com/KonstantinZsky/Another-Survivor/blob/main/Readme%20pics/minimap.png" alt="qr"/>
</picture>
### Реализованные игровые механики
Спавн противников, так чтобы не застревали в стенах. Простейший ИИ - просто идут на игрока. Урон и здоровье игрока и противников, анимация движения, покоя, анимация получения урона, анимация удара игрока. Анимации реализованы при помощи **AnimationTree**, **AnimationNodeStateMachine**, **BlendSpace1D**. **Object pool** для противников и усилений. Дроп опыта, накопление опыта. Первая итерация системы уровней.
### Использованные бесплатные ассеты
https://livingtheindie.itch.io/roguelite-survivor-asset-free-pack<br/>
https://opengameart.org/content/outdoor-tileset-0<br/>
https://opengameart.org/content/cyberpunk-noir-tileset<br/>
https://itch.io/queue/c/733269/godot-pixel-fonts?game_id=718254<br/>
https://opengameart.org/content/browserquest-sprites-and-tiles<br/>
https://github.com/mozilla/BrowserQuest<br/>
## TO DO
- Улучшить систему повышения уровня игрока.
- Новые противники, повышение сложности с течением времени, счетчик времени игровой сессии.
- Босс с состояниями реализованными через state machine. У меня уже есть опыт использования state machine<br/>
и т.д.
