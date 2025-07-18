class_name ConfirmationModal extends Control

## Signals a boolean of the confirmed state of the modal.
signal confirmed(is_confirmed: bool)

## Reference to the Header Label
@onready var header_label: Label = $CanvasLayer/ColorRect_BackGround/ColorRect_Video/Label_Header
## Reference to the Message Label
@onready var message_label: Label = $CanvasLayer/ColorRect_BackGround/ColorRect_Video/Label_Message
## Reference to the Confirm Button
@onready var confirm_button: Button = $CanvasLayer/ColorRect_BackGround/ColorRect_Video/VBoxContainer/Button_Confirm
## Reference to the Cancel Button
@onready var cancel_button: Button = $CanvasLayer/ColorRect_BackGround/ColorRect_Video/VBoxContainer/Button_Cancel

## Variable tracking the open state of the modal.
var is_open: bool = false

# Internal variable tracking if we should unpause after closing the modal.
var _should_unpause: bool = false

# my functions hide and show, cuz i use CanvasLayer
@onready var _canvas_layer : CanvasLayer = $CanvasLayer
func _hide() -> void:
	_canvas_layer.visible = false
func _show() -> void:
	_canvas_layer.visible = true

# Internal ready function for setup.
func _ready() -> void:
	set_process_unhandled_key_input(false)
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_button_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_button_pressed)
	_hide()


# Internal handler for key input.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancel()


## Calling this function will show this Confirmation Modal
## and awaits for a confirmation before closing. [br]
## [br]
## Usage:
## [codeblock]
## func _on_quit_button_pressed() -> void:
##     var conf = ConfirmationModalScene.instantiate()
##     var confirmed = await conf.customize(
##         "Are You Sure?", 
##         "Exit Game and return to desktop?",
##         "Exit Game"
##     ).prompt()
##     if confirmed:
##         get_tree().quit()
## [/codeblock]
func prompt(pause: bool = false) -> bool:
	_should_unpause = get_tree().paused == false and pause
	if pause:
		get_tree().paused = true
	_show()
	is_open = true
	set_process_unhandled_key_input(true)
	var is_confirmed = await confirmed
	return is_confirmed


## Calling this function will customize the Confirmation Modal.[br]
## [br]Takes [param header] for the Header text, [param message] for the Message text, and optional 
## [param confirm_text] for the Confirm Button text, and [param cancel_text] for the Cancel Button text.[br]
## [br]Returns the instance for chaining after customizing.
func customize(header: String, message: String, confirm_text: String = "Yes", cancel_text: String = "No") -> ConfirmationModal:
	header_label.text = header
	message_label.text = message
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	
	return self


## Closes the modal and confirms with a [param is_confirmed] boolean.
func close(is_confirmed: bool = false) -> void:
	if is_confirmed:
		confirm()
	else:
		cancel()


## Confirms the confirmation and hides the modal.
func confirm() -> void:
	_close_modal(true)


## Cancels the confirmation and hides the modal.
func cancel() -> void:
	_close_modal(false)


# Internal function to close the modal and cleanup
func _close_modal(is_confirmed: bool) -> void:
	set_process_unhandled_key_input(false)
	confirmed.emit(is_confirmed)
	set_deferred("is_open", false)
	_hide()
	if _should_unpause:
		get_tree().paused = false


# Internal handler for the confirm button being pressed.
func _on_confirm_button_pressed() -> void:
	confirm()


# Internal handler for the cancel button being pressed.
func _on_cancel_button_pressed() -> void:
	cancel()
