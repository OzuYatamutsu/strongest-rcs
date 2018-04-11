# Fish helper functions, converted to Python

def emphasize_text(color, text):
    return "set_color {color}; printf '{text}'; set_color normal;".format(
        color=color, text=text
    ) 

