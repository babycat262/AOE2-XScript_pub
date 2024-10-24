/***** 日历系统 *****/
include "calendar_buffs.xs"

// 触发器变量ID [0, 255]
const int TV_year = 101;    // 存储year值触发器变量ID
const int TV_month = 102;    // 存储month值触发器变量ID
const int TV_day = 103;    // 存储day值触发器变量ID
const int TV_yday = 104;    // 存储yday值触发器变量ID
// 根据year值确定是否闰年
int isLeap(int year=1000) {if((year%400 == 0) || (year%4 == 0) && (year%100 != 0)){return (1);} return (0);}


/*
    世界公历（函数版）使用方式：
    1. 修改calendar中的日历初始值参数：year, month, day, yday 
    2. 通过内置或外置方式加载以下XS脚本
    3. 在地图编辑器中新建触发A，设置：{状态：关闭，触发循环：开启}
    4. 触发A 新建条件和效果
      {条件0： 定时器，设置等待秒数为T（T: 日历最小更新间隔）
       效果0： XS脚本调用：calendar();
      }
    5. 新建触发B，状态开启。设置变量显示<TV_year> <TV_month> <TV_day> <TV_yday>，在UI面板中可看到触发器变量对应的日期信息
    6. 需要启动日历机制时，激活这个触发器即可
*/

/**
 * @brief 世界公历（函数版）：该函数按照一定间隔（触发器定时器，Rule间隔参数minInterval）循环运行，每次运行对日期更新，在场景中模拟出日历更新效果。
 * @param runs: 该日历函数的执行次数（全局累加）
 * @param leap: 闰年标识，{"非闰年": 0, "闰年": 1}
 * @fn isLeap: <int>该函数接收一个年份值，判断是否闰年，返回对应leap标识
 * @param year: 年份值（全局），取值范围：[0, +∞]
 * @param month: 月份值（全局），取值范围：[1, 12]
 * @param day: 月内天数（全局），取值范围：小月：[1,30]  大月：[1,31]  平二月|润二月：[1, 28|29]
 * @param yday: 一年内第几天（全局），取值范围：[1, 365|366]
 * @return <void> 
**/
void calendar()
{
    static int runs = 0;  // 日历运行次数
    static int leap = 0;  // 闰年标识符
    // 日历初始信息
    static int year =907;  // 始值年份
    static int month= 02;  // 始值月份
    static int day  = 04;  // 月内天数
    static int yday = 35;  // 一年内第Y天 [函数 get_yday(year,month,day) 的返回结果]
    if(isLeap(year)==1 && runs==0) {leap = 1;}  //确定初始年份的leap标识
    day++; yday++;    // 更新日期
    if(yday==32 || yday==60+leap || yday==91+leap 
       || yday==121+leap || yday==152+leap || yday==182+leap 
       || yday==213+leap || yday==244+leap || yday==274+leap 
       || yday==305+leap || yday==335+leap ) { month++; day=1; }
    else if(yday > 365+leap)
    {
        year++;
        month=1;
        day=1;
        yday=1;
        leap = isLeap(year);  //判断新的一年是否闰年
    }
    else {}
    // 同步触发器变量
    xsSetTriggerVariable(TV_year, year);
    xsSetTriggerVariable(TV_month, month);
    xsSetTriggerVariable(TV_day, day);
    xsSetTriggerVariable(TV_yday, yday);
    //solar_transform(1.0*month+0.01*day);    //将日期传入节气变化系统
    runs++;
}




/*
    世界日历（Rule版）使用方式：
    1. 修改规则 calendar 中的日历初始值参数：year, month, day, yday ，修改执行周期T1，设置Rule初始状态
    2. 通过 外置方式 加载以下XS脚本
    3. 在地图编辑器中新建触发A，设置：{状态：关闭，触发循环：关闭}
    4. 触发A 设置效果0：XS脚本调用： xsEnableRule("calendar");
    5. 新建触发B,设置变量显示<TV_year> <TV_month> <TV_day> <TV_yday>，在UI面板中可看到触发器变量对应的日期信息
    6. 当需要运行该日历机制时，激活触发器A即可，Rule将会按照指定周期跟新日期值。
    【注意事项】：若 Rule初始状态设置成 active，日历降级至将在游戏开始后自动激活运行，不需要做以上述 3，4，6步骤的设置

const int T1 = 60;    //Rule最小执行周期，代表日历中最小时间单位（天）的时长秒数
rule calendar
    inactive    //Rule初始状态 {active: 激活, inactive: 未激活}
    group Date
    minInterval T1
    //maxInterval T1
    priority 100
{
    static int runs = 0;  // 日历运行次数
    static int leap = 0;   // 闰年标识符
    // 日历初始信息
    static int year =907;  // 始值年份
    static int month= 02;  // 始值月份
    static int day  = 04;  // 月内天数
    static int yday = 35;  // 一年内第Y天 [函数 get_yday(year,month,day) 的返回结果]
    if(isLeap(year)==1 && runs==0) {leap = 1;}  //确定初始年份的leap标识
    // 更新日期
    day++; yday++;
    if(yday==32 || yday==60+leap || yday==91+leap 
       || yday==121+leap || yday==152+leap || yday==182+leap 
       || yday==213+leap || yday==244+leap || yday==274+leap 
       || yday==305+leap || yday==335+leap ) { month++; day=1; }
    else if(yday > 365+leap)
    {
        year++;
        month=1;
        day=1;
        yday=1;
        leap = isLeap(year);  //判断新的一年是否闰年
    }
    else {}
    // 同步触发器变量
    xsSetTriggerVariable(TV_year, year);
    xsSetTriggerVariable(TV_month, month);
    xsSetTriggerVariable(TV_day, day);
    xsSetTriggerVariable(TV_yday, yday);
    //solar_transform(1.0*month+0.01*day);    //将日期传入节气变化系统
    runs++;
}
*/
