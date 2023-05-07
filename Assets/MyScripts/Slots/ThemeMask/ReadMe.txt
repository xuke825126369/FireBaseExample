此代码针对目标: 这个遮罩主要用于 非弯曲关卡内部 符号。
此代码实现了哪些功能：针对正交照相机的 符号的矩形遮罩 And 符号内部元素的 Alpha遮罩
此代码 参考 CurveGroup 相关代码

此代码 相比 CurveGroup 相关代码 最大优势在于： Editor 功能 借助 SpriteRenderer 与 此代码新加的Editor ，使得 美术特效 开发 更为流畅

CustomerRectMaskGroup 缺陷:
1： Alpha遮罩 对 Tight MeshType格式 支持不完善
2: 对 透视照相机的遮罩存在问题（典型的问题： Scene 视图 与 Game 视图 遮罩结果不一致）

SpriteRenderer DrawCall 总结： 
1： DrawCall 受绘制顺序 影响
2： 移除屏幕的元素 不会产生 DrawCall 
3： 凡是对 材质 的属性进行 修改，都会增加DrawCall，所以 Alpha 遮罩 一定会增加DrawCall(除非绘制次序里 相邻元素 材质属性一致)
4： SortingGroup 影响绘制顺序，有可能会产生额外 DrawCall

UGUI DrawCall 总结： 
1： DrawCall 受绘制顺序 影响
2： 相同Canvas下的元素，只要有任何一个元素在屏幕中，那么其余移除屏幕的元素不会 减少DrwaCall
2： Canvas下的元素，Canvas SortingOrder 是 Overrided 且 只要没有任何一个元素在屏幕中，此Canvas 减少DrwaCall

SortingGroup 总结：
1： SortingGroup 影响绘制顺序，有可能会产生额外 DrawCall
2:  SortingGroup 动态添加删除 子节点 都会无规律导致报错： Assertion failed: Invalid SortingGroup index set in Renderer

SpriteMask 总结：
1：SpriteMask 虽然是采用模版进行遮罩，但是其只能更改Scale值来缩放Mask的范围，这无法使用九宫格的功能。
2:  多个SpriteMask 叠加在一起，会影响 模版值，模版值会因此累加（有CustomRange的话, 不同CustomRange 范围重叠的地方会 累加模版值，不重叠的地方不会。）没有CustomRange的话 会累加模版值


