class_name CustomButton extends TextureButton

var text: String = "":
    set(value):
        %ButtonText.text = value
    get():
        return %ButtonText.text
