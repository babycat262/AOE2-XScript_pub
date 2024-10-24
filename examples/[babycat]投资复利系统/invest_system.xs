/// 资源投资复利机制 ///


// round: 对实数 f_ 按照小数位数 n 进行四舍五入
mutable float round(float f_=0.0,int n=0){float num=0;int pn=pow(10,n);float pf=f_*pn;int ipf=1*pf; if(abs(pf-ipf)<0.5){num=1.0*ipf/pn;} else{num=1.0*(ipf+1)/pn;} return(num);}

void Fac1647Rate(float WR=0, float FR=0, float GR=0, float SR=0, int p=-1) 
{// 贸易工厂[1647]资源生成率设置[amt/sec]
    xsEffectAmount(1,243,0,WR/2.25,p); 
    xsEffectAmount(1,242,0,FR/2.25,p); 
    xsEffectAmount(1,245,0,GR/2.25,p); 
    xsEffectAmount(1,244,0,SR/2.25,p); 
}

//该机制作用的目标玩家
const int dest_p = 1;
// 每100点投资利润每秒产生的 肉、木、石 奖励点数
const float FOOD_RATE = 0.20;
const float WOOD_RATE = 0.16;
const float STONE_RATE= 0.10;
const float GOLD_RATE = 0.00;

int inv_history = -1;    // 投资历史列表
int back_rates = -1;    // 记录每期本金返还比例的数组
void invest_return_rate() 
{
    // 各期返还总本金和总利息比例的数组（索引值代表期数）
    back_rates = xsArrayCreateFloat(11, 0.0, "back_rates");
    xsArraySetFloat(back_rates, 0, 0.00);
    xsArraySetFloat(back_rates, 1, 0.06);
    xsArraySetFloat(back_rates, 2, 0.07);
    xsArraySetFloat(back_rates, 3, 0.08);
    xsArraySetFloat(back_rates, 4, 0.09);
    xsArraySetFloat(back_rates, 5, 0.10);
    xsArraySetFloat(back_rates, 6, 0.10);
    xsArraySetFloat(back_rates, 7, 0.11);
    xsArraySetFloat(back_rates, 8, 0.12);
    xsArraySetFloat(back_rates, 9, 0.13);
    xsArraySetFloat(back_rates,10, 0.14);
    // 记录投资历史的向量数组
    inv_history = xsArrayCreateVector(21, cOriginVector,"inv_history");
    xsArraySetVector(inv_history, 0, vector(0,0,0));
}

float inv_rate() 
{// 投资波动利率 (0.09 ~ 0.12)
    float rate_ = 0.0;
    int randp = xsGetRandomNumberLH(0, 100)+1;
    if(randp <= 25) {rate_ = 0.09;}  // p=0.25
    else if(randp > 25 && randp <= 55) {rate_ = 0.10;}  // p=0.30
    else if(randp > 55 && randp <= 80) {rate_ = 0.11;}  // p=0.25
    else if(randp > 80 && randp <=100) {rate_ = 0.12;}  // p=0.20
    else {}
    return (rate_);
}

float risk_invest(float amount=0.0) 
{// 投资风险，会造成本金亏损
    int risk_fac = xsGetRandomNumberLH(0, 100)+1;
    if(risk_fac%2 == 0) {return(amount);}  // (100%, 0.50)
    else if(risk_fac%3 == 0) {return (0.9*amount);}  // (90%, 0.17)
    else if(risk_fac%5 == 0) {return (0.7*amount);}  // (70%, 0.07)
    else if(risk_fac%7 == 0) {return (0.5*amount);}  // (50%, 0.04)
    else if(risk_fac%11== 0) {return (0.0*amount);}  // ( 0%, 0.01)
    else {}
    return (amount);
}

int finished_inv_midx(int arr_id=-1, int midx=1) 
{// 返回投资已完成批次的最小索引值
    float inv_term = 0.0;
    for(i = 1; <= 20) 
    {
        inv_term = xsVectorGetZ(xsArrayGetVector(inv_history, i));
        if(inv_term == 0) {midx = i; break;}
    }
    return (midx);
}

void benefitGenSRC(float benefit=0.0) 
{//与本期返还利润对应的资源生成率
    float food_ = benefit/100.0 * FOOD_RATE;
    float wood_ = benefit/100.0 * WOOD_RATE;
    float stone_= benefit/100.0 * STONE_RATE;
    xsEffectAmount(1, 242, 0, food_/2.25, dest_p);
    xsEffectAmount(1, 243, 0, wood_/2.25, dest_p);
    xsEffectAmount(1, 244, 0,stone_/2.25, dest_p);
}

int inv_batches = 0;    // 累计投资批次
int finished_batch = 0;    // 已经完成的投资批次
const int reward_T = 60;    // 回款周期T（游戏秒）
bool show_log = false;    // 显示投资过程中的日志信息
rule invest_reward
    inactive
    group INVEST
    minInterval reward_T
    maxInterval reward_T
    priority 50
{
    float reward_g1 = 0.0;    // 当期返还本金
    float reward_g2 = 0.0;    // 当期返还利息
    float reward_g = 0.0;    // 当期返还本息和
    int term_i =  -1;    // 期数缓存值
    vector invest_info = cOriginVector;
    //int history_size = xsArrayGetSize(inv_history);
    for(batch_i = 1; <= inv_batches) 
    {// 第 batch_i 次的投资详情
        invest_info = xsArrayGetVector(inv_history, batch_i);
        term_i = xsVectorGetZ(invest_info);
        if(term_i == 0) {// 若该次投资剩余期数为0，则该投资完成，跳过
            finished_batch++;
            if(show_log) {xsChatData("Finished invest batch: "+ finished_batch);}
            continue;
        }
        else 
        {
            reward_g1 = reward_g1 + xsArrayGetFloat(back_rates, 11-term_i) * xsVectorGetX(invest_info);
            reward_g2 = reward_g2 + xsArrayGetFloat(back_rates,    term_i) * xsVectorGetY(invest_info);
            // 更新该投资批次剩余期数
            invest_info = xsVectorSetZ(invest_info, term_i-1);
            xsArraySetVector(inv_history, batch_i, invest_info);
        }
    }
    // 进行风险投资，有29%概率亏损本金
    reward_g1 = risk_invest(reward_g1);
    if(show_log) {xsChatData("<AQUA>reward_g1: "+ reward_g1);  xsChatData("<ORANGE>reward_g2: "+ reward_g2);}
    reward_g = round(reward_g1+reward_g2, 2);
    xsEffectAmount(1, 3, 1, reward_g, dest_p);
    // 设置Food, Wood, Stone 生成点数
    benefitGenSRC(reward_g2);
    xsEffectAmount(1, 242, 0, (reward_g2/100.0*FOOD_RATE)/2.25, dest_p);
    xsEffectAmount(1, 243, 0, (reward_g2/100.0*WOOD_RATE)/2.25, dest_p);
    xsEffectAmount(1, 244, 0, (reward_g2/100.0*STONE_RATE)/2.25, dest_p);
  //xsEffectAmount(1, 245, 0, (reward_g2/100.0*GOLD_RATE)/2.25, dest_p);
    if(finished_batch >= inv_batches) 
    {// 失效的投资 >= 投资最大批次，禁用该规则
        Fac1647Rate(0,0,0,0,dest_p);
        finished_batch = 0;
        xsDisableSelf();
    }  
}

const int inv_terms = 10;    // 回款期数
const int KeepGold = 300;    // 黄金预留库存
void begin_invest() // 通过点击物体追加投资，更新投资金额
{
    // 超出预留金额KeepGold的部分用于投资
    float inv_gold = 1.0*xsPlayerAttribute(1,3) - KeepGold;
    //从玩家黄金储存中扣除投资金额 inv_gold
    xsEffectAmount(1, 3, 1, 0-inv_gold, dest_p);
    // 将该次投资信息 vector(本金, 利息, 期数)加入投资历史数组
    vector inv_detail = xsVectorSet(inv_gold, inv_gold*inv_rate(), inv_terms);
    xsArraySetVector(inv_history, finished_inv_midx(inv_history), inv_detail);
    if(inv_batches < 20) {inv_batches++;}
    if(xsIsRuleEnabled("invest_reward")!=true) {xsEnableRule("invest_reward");}
}


void main() 
{

    Fac1647Rate(0, 0, 0, 0, dest_p);    //贸易工厂资源生成率初始值
    invest_return_rate();    //投资各期数返还本金|利息的比例
}
