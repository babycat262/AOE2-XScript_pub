#include <iostream>
#include <vector>
using namespace std;


/**
 * @brief 向量类（Vector），包含成员属性 X_, Y_, Z_
 * @param X_: X分量
 * @param Y_: Y分量
 * @param Z_: Z分量
 * @return <Vector> Vector类型的实例
**/
class Vector {
public:
    float X_;    // X_分量
    float Y_;    // Y_分量
    float Z_;    // Z_分量

    Vector(float x_=0.0, float y_=0.0, float z_=0.0) 
    {// Vector 构造函数
        this->X_ = x_;
        this->Y_ = y_;
        this->Z_ = z_;
    }
    bool operator==(Vector& vec) 
    {//重载 == 运算符
        if(this->X_ == vec.X_ && this->Y_ == vec.Y_ && this->Z_ == vec.Z_) {return (true);}
        return (false);
    }
    bool operator!=(Vector& vec) 
    {//重载 != 运算符
        if(this->X_ == vec.X_ && this->Y_ == vec.Y_ && this->Z_ == vec.Z_) {return (false);}
        return (true);
    }
};

// 定义 cInvalidVector -> (-1, -1, -1)
Vector cInvalidVector = {-1.0, -1.0, -1.0};
// 定义 cOriginVector -> (0, 0, 0)
Vector cOriginVector = {0.0, 0.0, 0.0};
