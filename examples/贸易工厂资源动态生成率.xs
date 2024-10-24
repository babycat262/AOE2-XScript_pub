/**
 * @brief 设置贸易工厂1647动态资源生成率（分钟）
 * @param wood: 木材生成点数/min
 * @param food: 食物生成点数/min
 * @param gold: 黄金生成点数/min
 * @param stone: 石头生成点数/min
 * @param p: 玩家序号
 * @return <Bool> 生成率改变的标志。若rate发生改变返回true，否则返回false
**/
bool dynamic1647(int wood=0, int food=0, int gold=0, int stone=0, int p=-1) 
{
    static int stations = 0;
    float rate = 0.0;    // 工厂资源生成速率倍率 rate = 1/sqrt(x)
    int cur_factory = xsGetObjectCount(1, 1647);    //获取当前的贸易工厂数量
    if(stations != cur_factory) {
        stations = cur_factory;
        if(stations == 0) {rate = 0.0;}
        else if(stations > 0) {rate = 1.0/sqrt(stations);}
        xsEffectAmount(1, 243, 0, rate*wood/(2.25*60), p);
        xsEffectAmount(1, 242, 0, rate*food/(2.25*60), p);
        xsEffectAmount(1, 245, 0, rate*gold/(2.25*60), p);
        xsEffectAmount(1, 244, 0, rate*stone/(2.25*60),p);
        return (true);
    }
    return (false);
}
