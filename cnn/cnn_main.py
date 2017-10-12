#######################################
# background ##########################
#######################################
# Stanford's online classes: CS229 and
# CS231n. TensorFlow example code.
#
# Some .py files have some Windows and
# Linux directory differences (e.g. /home/user
# vs C:\Windows\).
#
# TensorFlow v1.2
#  Start with sanity check: MNIST Dataset
#  https://www.tensorflow.org/get_started/mnist/pros
#  Note: Filter sizes must be adjusted for MNIST!!
#
# Then move onto training with actual data (square images)

#######################################
# packages ############################
#######################################
 
# packages
import tensorflow as tf
import numpy as np
#import matplotlib.pyplot as plt
import time
 
#######################################
# function list  ######################
#######################################
 
start = time.time()
# textfile loader
def read_img_list(img_list, directory):
  f = open(img_list,'r')
  filenames = []
  labels = []
  for line in f:
    filename,label = line[:-1].split(' ')
    filenames.append(directory + filename)
    labels.append(int(label))    
  return filenames,labels

# image queue
def read_imgs_disk(input_queue,num_of_classes,num_of_pixels,num_of_channels):
  label = tf.one_hot(input_queue[1],depth = num_of_classes)
  label = tf.reshape(label, [num_of_classes])
  file_contents = tf.read_file(input_queue[0])
  imgs = tf.image.decode_png(file_contents,channels=1)
  imgs = tf.reshape(imgs, [num_of_pixels,num_of_pixels,num_of_channels])
  return imgs, label

# weight Gaussian initialization
def weight_variable(inputSize):
  initial = tf.truncated_normal(shape=inputSize, stddev=0.1)
  return tf.Variable(initial)

# bias constant initialization
def bias_variable(inputSize):
  initial = tf.constant(0.1,shape=inputSize)
  return tf.Variable(initial)

# convolution
def conv2d(x,W,strides):
  return tf.nn.conv2d(x, W, strides = strides, padding='SAME')

# max pool
def max_pool(x, ksize, strides):
  return tf.nn.max_pool(x, ksize=ksize, strides=strides, padding='SAME')

# ReLU non-linear activation unit
def relu(inputArray):
  return tf.nn.relu(inputArray)

# fully connected (FC)
def fc(inputArray, size, W, b):
  h_flat = tf.reshape(inputArray, size)
  return (tf.matmul(h_flat,W)+b)

# dropout
def dropout(inputArray, keep_prob):
  return tf.nn.dropout(inputArray,keep_prob)

#######################################
# operational parameters ##############
#######################################

os_is = 'win'
mnist_data = 'false'
num_epochs = 1

num_classes = 3
in_pixel = 110
num_channels = 1

num_test_imgs = 1000 # for MNIST
num_addition = 500 # for MNIST

#######################################
# data inputs #########################
#######################################

if mnist_data == 'false':
    if os_is == 'linux':
        file_train = "./input_list_train.txt"
        file_test = "./input_list_test.txt"
        directory = "./Training/train_sq/"
        directory_t = "./Training/test_sq/"
    else:
        file_train = ".\input_list_train_EMDHSN180.txt"
        file_test = ".\input_list_test_EMDHSN180.txt"
        directory = ".\cnn_train\HalfSecond180Noise\\"
        directory_t = ".\cnn_train\HalfSecond180Noise\Testing\\"    
    
    # training lists
    tr_img_list, tr_label_list = read_img_list(file_train,directory)
    tr_img_list = tf.convert_to_tensor(tr_img_list, dtype = tf.string)
    tr_label_list = tf.convert_to_tensor(tr_label_list, dtype = tf.int32)
    
    # test lists
    test_img_list, test_label_list = read_img_list(file_test,directory_t)   
    test_img_list = tf.convert_to_tensor(test_img_list, dtype = tf.string)
    test_label_list = tf.convert_to_tensor(test_label_list, dtype = tf.int32)

    # read data into TF
    input_queue = tf.train.slice_input_producer(
        [tr_img_list,tr_label_list],shuffle=False)     #num_epochs=num_epochs,shuffle=True)
    image, label = read_imgs_disk(input_queue,num_classes, in_pixel, num_channels)
    
    test_queue = tf.train.slice_input_producer(
        [test_img_list,test_label_list],shuffle=False)
    t_image, t_label = read_imgs_disk(test_queue,num_classes, in_pixel, num_channels)
else:
    # benchmark data
    from tensorflow.examples.tutorials.mnist import input_data
    mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

#######################################
# cnn layout ##########################
#######################################

# starting with simple design - sanity test
# conv2d: tensor shape [batch, in_height, in_width, in_channels] 
# kernel tensor shape [filter_height, filter_width, in_channels,out_channels]
# strides = [1, stride, stride, 1]

if mnist_data == 'false':
  x = tf.placeholder(tf.float32, shape=[None, in_pixel, in_pixel, num_channels])
  y_ = tf.placeholder(tf.float32, shape=[None, num_classes])
else:
  x = tf.placeholder(tf.float32, shape=[None, 784])
  y_ = tf.placeholder(tf.float32, shape=[None, 10])

keep_prob = tf.placeholder(tf.float32)

dropout_percent = 0.5 # Try the following changes:
filter1_depth = 5  # 10
filter2_depth = 10  # 25
filter3_depth = 20 # 35
fc1_depth = 25 # 10
iter_range = 3500 # 20000
batch_size = 30 # stochastic gradient descend
size_pool_final = 14 # h_pool3.eval({x:images_batch.eval()}).shape

# layer 1
W_conv1 = weight_variable([11,11,1,filter1_depth])
b_conv1 = bias_variable([filter1_depth])
conv_filter_stride = [1, 1 ,1, 1]
max_pool_ksize   = [1, 2, 2, 1]
max_pool_stride = [1, 2, 2, 1]

#in_image = tf.reshape(x, [-1, in_pixel, in_pixel, 1])

h_conv1 = relu(conv2d(x,W_conv1, conv_filter_stride) + b_conv1)
h_pool1 = max_pool(h_conv1, max_pool_ksize, max_pool_stride)

# layer 2
W_conv2 = weight_variable([5,5,filter1_depth,filter2_depth])
b_conv2 = bias_variable([filter2_depth])

h_conv2 = relu(conv2d(h_pool1, W_conv2, conv_filter_stride) + b_conv2)
h_pool2 = max_pool(h_conv2, max_pool_ksize, max_pool_stride)

# layer 3
W_conv3 = weight_variable([3,3,filter2_depth,filter3_depth])
b_conv3 = bias_variable([filter3_depth])

h_conv3 = relu(conv2d(h_pool2, W_conv3, conv_filter_stride) + b_conv3)
h_pool3 = max_pool(h_conv3, max_pool_ksize, max_pool_stride)

# fc layer
W_fc1 = weight_variable([size_pool_final*size_pool_final*filter3_depth,fc1_depth])
b_fc1 = bias_variable([fc1_depth])

#h_fc1 = relu(fc(h_conv5,[-1,14*14*384],W_fc1,b_fc1)) # batch commented
h_flat = tf.reshape(h_pool3, [-1,size_pool_final*size_pool_final*filter3_depth])
h_fc1 = tf.matmul(h_flat,W_fc1)+b_fc1
# dropout
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

# readout
W_fc2 = weight_variable([fc1_depth,num_classes])
b_fc2 = bias_variable([num_classes])

y_conv = tf.matmul(h_fc1_drop, W_fc2) + b_fc2

#######################################
# test and eval #######################
#######################################

cross_entropy = tf.reduce_mean(
    tf.nn.softmax_cross_entropy_with_logits(labels=y_, logits=y_conv))
train_step = tf.train.AdamOptimizer(0.5e-4).minimize(cross_entropy)
correct_prediction = tf.equal(tf.argmax(y_conv, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

#######################################
# running interactive sessions ########
#######################################

#sesh = tf.InteractiveSession()
#init_op = tf.global_variables_initializer()
#sesh.run(init_op)
#abc = [input_queue[0].eval(), input_queue[1].eval()]
#batch = mnist.train.next_batch(1)
#images_batch, labels_batch = tf.train.batch(
#            [image, label], batch_size=1)

#test_images, test_labels = tf.train.batch([t_image,t_label], batch_size=30)
#coord = tf.train.Coordinator()
#threads = tf.train.start_queue_runners(coord=coord)
#feed_dict={x: image.eval(), y_: label.eval()}
#feed_dict={x: batch[0], y_: batch[1], keep_prob:1.0}
#feed_dict={x: images_batch.eval(), y_: labels_batch.eval(), keep_prob:1.0}
#train_step.run(feed_dict=feed_dict)
#h_conv3.eval({x:images_batch.eval()}).shape

#feed_dict={x: test_images.eval(), y_: test_labels.eval(),keep_prob:1.0} 
#print("test accuracy %g" % accuracy.eval(feed_dict))

#abc = [images_batch.eval(), labels_batch.eval()]
#labels_batch.eval()
#fig, ax = plt.subplots()
#im = ax.imshow(abc[0].reshape((110,110)))
#plt.show()

#######################################
# running graph sessions ##############
#######################################

print("\ntraining...\n")
if mnist_data == 'true':
    # run: the MNIST images
    with tf.Session() as sesh:
      sesh.run(tf.global_variables_initializer())
      for i in range(iter_range):
        batch = mnist.train.next_batch(batch_size)
        if i % 100 == 0:
          train_accuracy = accuracy.eval(feed_dict={
              x: batch[0], y_: batch[1], keep_prob: 1.0})
          print('step %d, training accuracy %g' % (i, train_accuracy))
        train_step.run(feed_dict={x: batch[0], y_: batch[1], keep_prob: dropout_percent})
     
      # test. NOTE: due to out of memory error the test images are split into batches
      acc = 0
      feed_dict={x: mnist.test.images[0:num_test_imgs][:], y_: mnist.test.labels[0:num_test_imgs], keep_prob: 1.0}
      acc = acc + accuracy.eval(feed_dict)
      feed_dict={x: mnist.test.images[num_test_imgs:num_test_imgs+num_addition][:], y_: mnist.test.labels[num_test_imgs:num_test_imgs+num_addition], keep_prob: 1.0}
      acc = acc + accuracy.eval(feed_dict)
      feed_dict={x: mnist.test.images[num_test_imgs+num_addition:num_test_imgs+num_addition*2][:], y_: mnist.test.labels[num_test_imgs+num_addition:num_test_imgs+num_addition*2], keep_prob: 1.0}
      acc = acc + accuracy.eval(feed_dict)
      acc = acc/3
      print('test accuracy %g' % acc)
else:
    # run: the images from the thesis
    with tf.Session() as sesh:
      init_op = tf.global_variables_initializer()
      sesh.run(init_op)
      image_batch, label_batch = tf.train.shuffle_batch(
            [image, label], batch_size=batch_size,
            capacity=50,
            min_after_dequeue=1)
      coord = tf.train.Coordinator()
      threads = tf.train.start_queue_runners(coord=coord)      
      for i in range(iter_range):
        #images_batch, labels_batch = sesh.run([image,label])
        #print(labels_batch)
        #print('\n')        
        images_batch, labels_batch = sesh.run([image_batch,label_batch]) # Note: THIS KEY LINE KEEPS LABEL AND IMAGE IN SYNC!!!!
        #images_batch, labels_batch = tf.train.batch(
        #    [image, label], batch_size=40)
        #batch_size=40
        #image_array = tf.zeros([batch_size, in_pixel, in_pixel, num_channels],tf.float32)
        #for j in range(batch_size):
        #    image, label = read_imgs_disk([tr_img_list[j],tr_label_list[j]],num_classes, in_pixel, num_channels)
        #    image_array[j,:,:,:], label_array[j,:] = sesh.run([image, label])
        #    print(label_array[j,:])
        #    print('\n')
        #    fig, ax = plt.subplots()
        #    im = ax.imshow(image_array[j,:,:,:].reshape((110,110)))
        #    plt.show()

        #data_batch,label_batch=sess.run([images_batch,labels_batch])            
        # seems like we need to feed some images by sesh.run([image, label]) which iterates through
        if i % 100 == 0:
          #feed_dict={x: image.eval(), y_: label.eval()}
          #feed_dict={x: images_batch.eval(), y_: labels_batch.eval(),keep_prob:1.0}
          feed_dict={x: images_batch, y_: labels_batch,keep_prob:1.0}
          train_accuracy = accuracy.eval(feed_dict)
          print('step %d, training accuracy %g' % (i, train_accuracy))
        feed_dict={x: images_batch, y_: labels_batch,
                  keep_prob:dropout_percent}
        train_step.run(feed_dict)
      coord.request_stop()
      coord.join(threads)

      print("training finished.\nstarting test set...")
      
      #test_images, test_labels = tf.train.batch([t_image,t_label], batch_size=10)
      #coord = tf.train.Coordinator()
      #threads = tf.train.start_queue_runners(coord=coord)
      #feed_dict={x: test_images.eval(), y_: test_labels.eval(),keep_prob:1.0}
      #test_set_acc=0
      #test_set_acc = accuracy.eval(feed_dict)
      #print("test accuracy (thesis) %g" % test_set_acc)  
      #coord.request_stop()
      #coord.join(threads)
      
      acc = 0
      size_test_set = test_img_list.shape[0]
      for j in range(size_test_set):
        t_image, t_label = read_imgs_disk([test_img_list[j],test_label_list[j]],num_classes, in_pixel, num_channels)
        t_image, t_label = sesh.run([t_image, t_label])
        feed_dict={
            x: t_image.reshape(1,in_pixel,in_pixel,num_channels), 
            y_: t_label.reshape(1,num_classes),
            keep_prob: 1.0}
        acc_now = accuracy.eval(feed_dict)
        #print(y_conv.eval(feed_dict))
        acc = acc + acc_now
        #print(t_label)
        #print('\n')
        #fig, ax = plt.subplots()
        #im = ax.imshow(t_image.reshape((110,110)))
        #plt.show()
        
      #print('test accuracy %g' % accuracy.eval(feed_dict={x: t_image.eval(), y_: t_label.eval()}))
      #print("test accuracy: %f" % (acc/26))
      test_set_acc = acc/int(size_test_set)
      print("testing set finished.\n")
      
      #acc = accuracy.eval(feed_dict={x: t_image.eval(), y_: t_label.eval()})
      #print("test accuracy: %f" % (acc/31))
        #img = image[i].eval()
        #sesh.run([image,label])
         
      #print(img1.shape)
      #np.asarray(image).show()
      
print("thesis test accuracy: %g" % test_set_acc)
end = time.time()
total_time = end-start
hour = int(total_time/3600)
minute = int((total_time%3600)/60)
second = int((total_time%3600)%60)
print("Total running time is {}:{}:{}. ".format(hour,minute,second))
