extends VBoxContainer
class_name CreditItem
@onready var commit: Label = %Commit
@onready var author: Label = %Author

func display(credit: Credit) -> void:
	commit.text = credit.commit
	author.text = credit.author
