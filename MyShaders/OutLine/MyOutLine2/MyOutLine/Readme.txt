使用Post形式进行的OUtline的渲染
方案如下：
1 使用了Soble算子获取边缘
2 把要进行Outline处理的物体的设置Alpha为0，其中参考ShowPlaneColor.shader
同时Stencil设置为2
3 在后期处理中对Alpha为0的区域先获取边缘
4 在后期处理中进行Bloom处理，目标区域是Stencil不为2的区域
