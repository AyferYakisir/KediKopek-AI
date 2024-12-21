import tensorflow as tf

interpreter = tf.lite.Interpreter(model_path="C:/Users/Ayfer/Downloads/model_unquant.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input Shape:", input_details[0]['shape'])
print("Output Shape:", output_details[0]['shape'])
