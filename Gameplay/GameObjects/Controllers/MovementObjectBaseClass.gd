class_name MovementObjectBaseClass
extends Node2D

# Все переменные будут в этом словаре, чисто для удобства написания кода.
# При наследовании буду обращаться к этим переменным через myMovementData
#	и будет понятно что это и откуда. 
var myMovementData : Dictionary = {
	# Зачем предыдущий поворот? Для расчета скорости (конкретно - торможения)
	# Таким образом можно удобно разделить функцию вращения и движения.
	# Сначала должна вызываться функция вращения.
	previous_rotation = 0.0,
	#  После расчета вращения - самый последний градус поворота,
	#	при расчете старое значение толкается в previous_rotation
	current_rotation = 0.0,
	# Текущая позиция объекта
	# Для игрока это позиция на экане, для игровых объектов - на игровом поле
	# Нужна для расчета поворота до цели поворота
	pos = Vector2(0.0,0.0),
	# Текущая позиция цели поворота
	# Для игрока это позиция мыши на экане, для игровых объектов - на игровом поле
	# Нужна для расчета поворота до цели поворота
	turn_target = Vector2(0.0,0.0),
	# Текущая скорость поворота, по идее задается только 1 раз,
	#	но вполне может быть что для геймплея будет меняться
	turn_speed = 0.0, # В градусах?
	degrees_to_target = 0.0, # Градусов до цель ДО рассчета (справочно)
	
	# Угол движения в градусах, может быть равен current_rotation
	#	или же под углом (к углу), если это стрейф.
	# При расчете поворота будет приравнен к current_rotation, 
	#	перед расчетом движения можно поменять
	move_target_angle = 0.0,
	# Скорость объекта (до расчета движения - прошлая)
	# Ее не надо задавать, она обновится сама при расчете
	speed = Vector2(0.0,0.0),	
	# Текущее ускорение, может меняться
	#	Например для игрока для разных видов стрейфа
	acceleration = 0.0,
	# Текущее торможение, для геймплея может меняться (наверное)
	deacceleration = 0.0,
	# Максимально допустимая скорость, по умолчанию 0, 
	#	так что не будет двигаться, если не задать
	max_speed = 0.0
}

# Вычислем поворот и возвращаем, так же обновляем значения в myMovementData
func calc_rotation(delta : float) -> float:
		
	var vector_to_target = myMovementData.turn_target-myMovementData.pos
	var degrees_to_target = _myCalculateAngle(vector_to_target.y,vector_to_target.x)*180.0/PI+90
	myMovementData.degrees_to_target = degrees_to_target

	var degrees_deviation = myMovementData.current_rotation - degrees_to_target	
	
	# Если есть отклонение то поворачиваем
	#	проблема если переходим через 360 градусов...
	# 	нужно найти ближайший угол поворота
	var degrees_to_turn = 0.0
	if degrees_deviation > 0.0:
		if degrees_deviation < 180.0:
			# Текущий угол и угол мыши близко, при этом текущий впереди
			#  ближе двигаться назад
			degrees_to_turn = -myMovementData.turn_speed*delta
			# Чтоб не повернуть слишком сильно
			degrees_to_turn = -min(-degrees_to_turn,degrees_deviation)
		else: # > 180
			# Большой текущий угол, маленький к мышке, ближе двигаться в плюс
			degrees_to_turn = myMovementData.turn_speed*delta
			# Чтоб не повернуть слишком сильно
			degrees_to_turn = min(degrees_to_turn,360-degrees_deviation)	
	if degrees_deviation < 0.0:
		if degrees_deviation > -180.0: 
			# Текущий угол и угол мыши близко, при этом мышь впереди
			#  ближе двигаться вперед
			degrees_to_turn = myMovementData.turn_speed*delta
			# Чтоб не повернуть слишком сильно
			degrees_to_turn = min(degrees_to_turn,-degrees_deviation)
		else: # < -180
			# Большой угол мыши, маленький текущий, ближе двигаться в минус
			degrees_to_turn = -myMovementData.turn_speed*delta	
			# Чтоб не повернуть слишком сильно
			degrees_to_turn = -min(-degrees_to_turn,360.0+degrees_deviation)		

	var new_object_rotation = _calc_turn(myMovementData.current_rotation,degrees_to_turn)			
	
	# Сохраняем старое вращение для расчета скорости
	myMovementData.previous_rotation = myMovementData.current_rotation
	
	# Обновляем вращение
	myMovementData.current_rotation = new_object_rotation
	myMovementData.move_target_angle = new_object_rotation
	
	# Возвращаем
	return new_object_rotation

# Вычисляем новую скорость и возвращаем, так же обновляем значения в myMovementData
func calc_velocity(delta : float) -> Vector2:
	
	var object_move_direction_rad : float = myMovementData.move_target_angle/180*PI-90/180*PI
		
	# Тут точно есть движение и вектор, вариант без движение уже сделал return
	# Есть последняя (уже старая) скорость velocity, надо спроецировать
	#	ее на новое направление, нужен вектор нового направление
	var new_direction_vector = Vector2(cos(object_move_direction_rad),sin(object_move_direction_rad))
	# Проекция на новое направление
	var velocity_projected : Vector2 = myMovementData.speed.project(new_direction_vector)
	# Остаток скорости не по направлению
	var velocity_remainder : Vector2 = myMovementData.speed - velocity_projected
	
	# Применяем торможение к остатку скорости не по направлению
	velocity_remainder = _cacl_deacceleration(delta,velocity_remainder)
	
	# Теперь меняем часть скорости которая по направлению корабля и прибавляем остаток
	var speed_to_add : float = myMovementData.acceleration * delta
	var speed_to_add_vector : Vector2 = speed_to_add * new_direction_vector

	# Без ограничения макс скорости
	# 	!! без velocity_remainder, сначала ограничим по макс скорости!
	var new_velocity_raw = velocity_projected + speed_to_add_vector
	
	# Альтернативный способо рассчета
	# Торможение сразу на всю старую скорость
	#var velocity_after_deaccel : Vector2 = _cacl_deacceleration(delta,myMovementData.speed)
	# Теперь прибавляем ускорение
	#var new_velocity_raw = velocity_after_deaccel + speed_to_add_vector
	
	# КАК ОГРАНИЧИТЬ МАКСИМАЛЬНУЮ СКОРОСТЬ У ВЕКТОРА?
	#  рассчитать вектор максимальной скорости
	var max_speed_vector : Vector2 = myMovementData.max_speed * new_direction_vector		
	
	# Накладываем ограничение скорости
	# ! Теперь мне нужно не резко обрезать скорость при превышении максимума,
	#  а наложить торможение (вплоть до достижения макс скорости и там остановиться)
		# Если макс скорость превышена и нам нужно тормозить
	var speed_to_substract_vector : Vector2 = new_direction_vector * myMovementData.deacceleration * delta	
	var new_velocity = Vector2(0.0,0.0)
	if max_speed_vector.x < 0.0:
		# Сначала проверим скорость до прибавления ускорения
		if velocity_projected.x < max_speed_vector.x:
			# Никакое ускорение прибавлять не нужно, и так максимум превышен
			# Применим торможение
			var new_velocity_add_deaccel_x : float = velocity_projected.x - speed_to_substract_vector.x	
			# Торможение не завело ниже максимума, берем как скорость
			if 	new_velocity_add_deaccel_x < max_speed_vector.x:
				new_velocity.x = new_velocity_add_deaccel_x
			# Торможение опустило ниже максимума, обрезаем по максимому
			else: # new_velocity_add_deaccel_x > max_speed_vector.x
				new_velocity.x = max_speed_vector.x
		else: # velocity_projected.x > max_speed_vector.x:
			# Максимум не превышен, можно проверять дальше		
			if new_velocity_raw.x < max_speed_vector.x:	
				# После прибавки ускорения максимум превышен
				# обрезаем по максимому
				new_velocity.x = max_speed_vector.x		
			else: # new_velocity_raw.x > max_speed_vector.x:
				# После прибавки ускорения все еще меньше максимума
				# берем как итоговую скорость
				new_velocity.x = new_velocity_raw.x
	else: # max_speed_vector.x > 0.0
		if velocity_projected.x > max_speed_vector.x:
			var new_velocity_add_deaccel_x : float = velocity_projected.x - speed_to_substract_vector.x	
			if 	new_velocity_add_deaccel_x > max_speed_vector.x:
				new_velocity.x = new_velocity_add_deaccel_x
			else: # new_velocity_add_deaccel_x < max_speed_vector.x
				new_velocity.x = max_speed_vector.x
		else: # velocity_projected.x < max_speed_vector.x:	
			if new_velocity_raw.x > max_speed_vector.x:	
				new_velocity.x = max_speed_vector.x		
			else: # new_velocity_raw.x < max_speed_vector.x:
				new_velocity.x = new_velocity_raw.x		
	
	if max_speed_vector.y < 0.0:
		if velocity_projected.y < max_speed_vector.y:
			var new_velocity_add_deaccel_y : float = velocity_projected.y - speed_to_substract_vector.y	
			if 	new_velocity_add_deaccel_y < max_speed_vector.y:
				new_velocity.y = new_velocity_add_deaccel_y
			else: # new_velocity_add_deaccel_y > max_speed_vector.y
				new_velocity.y = max_speed_vector.y
		else: # velocity_projected.y > max_speed_vector.y:	
			if new_velocity_raw.y < max_speed_vector.y:	
				new_velocity.y = max_speed_vector.y		
			else: # new_velocity_raw.y > max_speed_vector.y:
				new_velocity.y = new_velocity_raw.y
	else: # max_speed_vector.y > 0.0
		if velocity_projected.y > max_speed_vector.y:
			var new_velocity_add_deaccel_y : float = velocity_projected.y - speed_to_substract_vector.y	
			if 	new_velocity_add_deaccel_y > max_speed_vector.y:
				new_velocity.y = new_velocity_add_deaccel_y
			else: # new_velocity_add_deaccel_y < max_speed_vector.y
				new_velocity.y = max_speed_vector.y
		else: # velocity_projected.y < max_speed_vector.y:	
			if new_velocity_raw.y > max_speed_vector.y:	
				new_velocity.y = max_speed_vector.y		
			else: # new_velocity_raw.y < max_speed_vector.y:
				new_velocity.y = new_velocity_raw.y		
		
#region Старая обработка максимума
	#if max_speed_vector.x < 0.0:
		## Не понимаю почему клемп не работает как надо, сделаю через иф
		##new_velocity.x = clamp(new_velocity_raw.x,max_speed_vector.x,new_velocity_raw.x)
		#if new_velocity_raw.x < max_speed_vector.x:
			## Чет не то, зачем прибавлять ускорение, если мы превысили макс скорость?
			## надо на макс скорость проверять до прибавления ускорения
			#var new_velocity_add_deaccel_x : float = new_velocity_raw.x - speed_to_substract_vector.x
			#if new_velocity_add_deaccel_x > max_speed_vector.x:
				#new_velocity.x = max_speed_vector.x
			#else: new_velocity.x = new_velocity_add_deaccel_x
		#else: new_velocity.x = new_velocity_raw.x
	#else :
		#if new_velocity_raw.x > max_speed_vector.x : 
			#var new_velocity_add_deaccel_x : float = new_velocity_raw.x - speed_to_substract_vector.x
			#if new_velocity_add_deaccel_x < max_speed_vector.x:
				#new_velocity.x = max_speed_vector.x
			#else: new_velocity.x = new_velocity_add_deaccel_x
		#else: new_velocity.x = new_velocity_raw.x
		#
	#if max_speed_vector.y < 0.0:
		##new_velocity.y = clamp(new_velocity_raw.y,max_speed_vector.y,new_velocity_raw.y)
		#if new_velocity_raw.y < max_speed_vector.y: 
			#var new_velocity_add_deaccel_y : float = new_velocity_raw.y - speed_to_substract_vector.y
			#if new_velocity_add_deaccel_y > max_speed_vector.y:
				#new_velocity.y = max_speed_vector.y
			#else: new_velocity.y = new_velocity_add_deaccel_y			
		#else: new_velocity.y = new_velocity_raw.y
	#else :
		##new_velocity.y = clamp(new_velocity_raw.y,new_velocity_raw.y,max_speed_vector.y)
		#if new_velocity_raw.y > max_speed_vector.y :
			#var new_velocity_add_deaccel_y : float = new_velocity_raw.y - speed_to_substract_vector.y
			#if new_velocity_add_deaccel_y < max_speed_vector.y:
				#new_velocity.y = max_speed_vector.y
			#else: new_velocity.y = new_velocity_add_deaccel_y			 
		#else: new_velocity.y = new_velocity_raw.y		
#endregion
	
	# Теперь прибавим остаток скорости не по направлению
	#	на него не надо накладывать ограничение, это неверно
	myMovementData.speed = new_velocity + velocity_remainder
	
	return myMovementData.speed

# Вспомогательная функция рассчета торможения
#	Если есть направление движения то торможение вычисляется только
#	для остатка скорости не по направлению. Если кнопки движения не нажаты
#	то торможение накладывается на всю скорость
#	На что накладывается торможение определяется вне этой функции
#	Сюда передается только вектор на который нужно наложить торможение
func _cacl_deacceleration(dlt : float, spd_old : Vector2) -> Vector2:	
	var current_deacceleration : float = myMovementData.deacceleration * dlt
	var spd = spd_old
	
	# Применяем торможение к Х
	if spd.x >= 0:
		#spd.x = clamp(spd.x-current_deacceleration,0,spd.x)
		# Проблемы с торможением, попробую через if
		spd.x = spd.x-current_deacceleration
		if spd.x < 0 : spd.x = 0
	else : # spd.x < 0
		#spd.x = clamp(spd.x+current_deacceleration,spd.x,0)
		spd.x = spd.x+current_deacceleration
		if spd.x > 0 : spd.x = 0
	# Применяем торможение к Y
	if spd.y >= 0:
		#spd.y = clamp(spd.y-current_deacceleration,0,spd.y)
		spd.y = spd.y-current_deacceleration
		if spd.y < 0 : spd.y = 0
	else : # spd.x < 0
		#spd.y = clamp(spd.y+current_deacceleration,spd.y,0)	
		spd.y = spd.y+current_deacceleration
		if spd.y > 0 : spd.y = 0
	return spd

# Применяет поворот к углу
#	Сохраняет положительный знак градуса,путем прибавления 360
#	Сохраняет значение поворта меньше 360 путем вычитания 360
func _calc_turn(rot_old : float, turn : float) -> float:
	var rot = rot_old + turn	

	if rot > 360.0 : 
		rot = rot - 360.0
	if rot < 0.0 :	
		rot = rot + 360.0

	return 	rot

# Почему-то atan2 возвращает угол: 0 270 -90,
#	сделал свой расчет угла: 0 360
static func _myCalculateAngle(y : float, x : float) -> float:
	var angle : float = 0.0
	if x == 0.0:
		angle = -PI/2.0
		#if y == 0.0:
		#	angle = 0.0
		#elif y > 0.0:
		#	angle = PI/2.0
		#else:
		#	angle = PI/2.0
	else:
		angle = atan(y/x)
		if x < 0.0:
			if y > 0.0:
				angle += PI
			elif y < 0.0:
				# angle -= PI
				angle += PI
			else:
				angle = PI
	return angle
