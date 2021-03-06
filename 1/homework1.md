% 第一次编程作业
% 无36
  李思涵
  2013011187
  <lisihan969@gmail.com>
% \today

# 题目

某信道，输入为 $M$ 元逻辑符号 $x: s_0, s_1, \cdots, s_{M-1}$，输出 $y$ 为实数值。
信道中发生如下事件：

- $a = f(x)$ 到实数的一一映射，当 $x = s_i$ 时，$a = iA$，$A$ 为一给定的正实数
- $y = a + n$，$n$ 为一服从 $N(0, \sigma^2)$ 分布的独立随机变量（与 $x$ 独立，且每次信道实现时的 $n$ 均独立）

1. 写出信道转移概率 $p(y\mid x = s_i)$
2. 若输入信道的各符号等概出现，求该信道的互信息量
3. 画出不同信噪比下的互信息量变化的曲线，以 $M$ 为参数，画一簇曲线（其中加上一条 AWGN 信道容量曲线作对比）
4. 调整函数 $a = f(x)$，使当 $x = s_i$ 时，$a = iA ‐ b$ ，$b$ 也为一实常数，在 $A$ 和 $\sigma$ 不变的情况下，互信息量随 $b$ 的变化情况是什么趋势？
5. $b$ 的取值对互信息量随信噪比的变化曲线的影响？

# 理论推导

## 信道转移概率

记噪声 $n$ 的概率密度函数为 $f(n)$，则易知

\[
  f(n) = \frac{1}{\sigma\sqrt{2\pi}}e^{-\frac{n^2}{2\sigma^2}}
\]

当 $x = s_i$ 时，$a = iA$，故 $y = a + n$ 的条件概率密度函数为

\[
  p(y\mid x = s_i) = \frac{1}{\sigma\sqrt{2\pi}}e^{-\frac{(y-iA)^2}{2\sigma^2}}
\]

## 信道的互信息量

对于 $f(n)$，其熵为

\[
  H(N) = \log{2}{\sigma\sqrt{2\pi e}}\ (\text{bit})
\]

而 $y$ 的概率密度函数为

\[
  p(y) = \sum_{i=0}^{M-1}{P(X = s_i)p(y\mid x = s_i)}
       = \frac{1}{M}\sum_{i=0}^{M-1}\frac{1}{\sigma\sqrt{2\pi}}e^{-\frac{(y-iA)^2}{2\sigma^2}}
\]


故平均互信息量为

\[
  I(X, Y) = H(Y) - H(N) = -\int_{-\infty}^{\infty}{p(y)\log_2{p(y)}dy} - 
                          \log_2{\sigma\sqrt{2\pi e}}\ (\text{bit})
\]

## 互信息量与信噪比的关系

噪声功率 $N$ 满足

\[
  N = \sigma^2
\]

信号功率 $S$ 则满足

\[
  S = \sum_{i=0}^{M-1}{p(x = s_i)(iA-b)^2}
    = \frac{A^2(M-1)(2M-1)-6Ab(m-1)+6b^2}{6}
\]

即可得到 $\sigma$ 与信噪比的关系

\[
  \sigma = \sqrt{\frac{A^2(M-1)(2M-1)-6Ab(m-1)+6b^2}{6\frac{S}{N}}}
\]

将 $\sigma$ 带入互信息量的表达式，即可以得到互信息量与信噪比的关系。

## 最大互信息量

由香农公式，我们自然有

\[
  I_{\text{max}}(X, Y) = \frac{1}{2}\log_2{(1+\frac{S}{N})}
\]

# 数值模拟

我们在 Mathematica 10.1.0.0 中进行数值模拟。

## 不同信噪比下的互信息量变化

假设 $A$ 为 1。代码如下：

```mathematica
g[snr_, m_] := 
  Hold@Module[{\[Sigma] = Sqrt[((m - 1) (2 m - 1))/(6 snr)], p},
    p = 1/
      m Sum[1/(\[Sigma] Sqrt[2 \[Pi]])
         E^(-((y - i)^2/(2 \[Sigma]^2))), {i, 0, m - 1}];
    -NIntegrate[ p Log2[p], {y, -Infinity, Infinity}] - 
     Log2[\[Sigma] Sqrt[2 \[Pi] E]]
    ];
Plot[
 Evaluate@With[{snr = 10^(snrdb/10)},
   Append[Table[g[snr, m], {m, 2, 10, 2}],
    1/2 Log2[1 + snr]
    ]],
 {snrdb, 0, 30}, PlotPoints -> 10,
 PlotLegends -> 
  Append[Table["M=" <> ToString[m], {m, 2, 10, 2}], "AWGN"],
 AxesLabel -> {"SNR(dB)", "I(X,Y)"}
 ]
```

![互信息量与信噪比的关系](I-SNR-M.png)

从图中，我们可以看出以下规律：

- 当 $M$ 取定时，互信息量随着信噪比的增大而增大，但最终会达到一极限值。

    这是因为，在信噪比较大的时候，真正限制互信息量的是信道的容量，也就是 $M$ 的大小。

- 互信息量的极限值随着 $M$ 的增大而增大。

    这是因为当信噪比趋向于无穷大时，信道的容量便成了互信息量的主要限制因素。实际上，这一极限就
    是信道能传递的信息极限 $\log_2{M}$。

- 无论 $M$ 和信噪比如何取值，互信息量总与 AWGN 信号的互信息量有一定差距（在信噪比趋向无穷时
  趋向于 1）。

    这是因为，在这种编码方式下，输入信号非负，在信噪比趋向于无穷时，有一半的信道时空闲的。
    所以，同样信噪比下其能传递的信息便少了一半，也就是 1 比特。

- 在信噪比较小时，互信息量与 $M$ 负相关；信噪比较大时，互信息量与 $M$ 正相关。

    可以这样考虑：在信噪比较大时，信道容量的增加能够传递更多的信息。然而，在信噪比很小时，
    过大的 $M$ 反而会增大各符号之间的干扰，使接收方无法分辨各符号，从而减少互信息量。

## 互信息量随 $b$ 的变化

假设 $A$, $\sigma$ 都为 1。代码如下：

```mathematica
f[m_, b_] := Hold@Module[{\[Sigma] = 1, p},
    p = 1/
      m Sum[1/(\[Sigma] Sqrt[2 \[Pi]])
         E^(-((y - i + b)^2/(2 \[Sigma]^2))), {i, 0, m - 1}];
    -NIntegrate[ p Log2[p], {y, -Infinity, Infinity}] - 
     Log2[\[Sigma] Sqrt[2 \[Pi] E]]
    ];
Plot[
 Evaluate@Table[f[m, b], {m, 2, 10, 2}],
 {b, -2, 2}, PlotPoints -> 6,
 PlotLegends -> Table["M=" <> ToString[m], {m, 2, 10, 2}],
 AxesLabel -> {"b", "I(X,Y)"}
 ]
```

![互信息量与 $b$ 的关系](I-b.png)

可以看到，互信息量完全不受 $b$ 的影响。这一点实际上很显然。因为在 $M$ 给定的情况下，$b$ 的
作用只是使输入符号整体平移，并没有改变它们的相对位置，所以不会给接收方带来任何信息上的变化。
故不回改变互信息量。

## $b$ 的取值对互信息量随信噪比的变化曲线的影响

假设 $A$为 1，$M$ 为 5。代码如下：

```mathematica
h[snr_, b_] := Hold@Module[{m = 5, \[Sigma], p},
    \[Sigma] = Sqrt[((m - 1) (2 m - 1) - 6 b (m - 1) + 6 b^2)/(6 snr)];
    p = 1/
      m Sum[1/(\[Sigma] Sqrt[2 \[Pi]])
         E^(-((y - i + b)^2/(2 \[Sigma]^2))), {i, 0, m - 1}];
    -NIntegrate[ p Log2[p], {y, -Infinity, Infinity}] - 
     Log2[\[Sigma] Sqrt[2 \[Pi] E]]
    ];
Plot[
 Evaluate@With[{snr = 10^(snrdb/10)},
   Append[Table[h[snr, b], {b, -2, 2, 1}],
    1/2 Log2[1 + snr]
    ]],
 {snrdb, 0, 30}, PlotPoints -> 4,
 PlotLegends -> 
  Append[Table["b=" <> ToString[b], {b, -2, 2, 1}], "AWGN"],
 AxesLabel -> {"SNR(dB)", "I(X,Y)"}
 ]
```

![$b$ 的取值对互信息量随信噪比的变化曲线的影响](I-SNR-b.png)

可以发现以下规律：

- $b$ 对信噪比趋于无穷时的渐近线没有影响，不同 $b$ 的取值只造成了图像的左右平移。

    正如我们前面所分析的，该渐近线是带宽有限的缘故，与 $b$ 没有关系。实际上，$b$ 改变的只有
    信号的功率，也就是互信息量不变情况下的信噪比。故函数图像之发生了左右平移。

- $b$ 取 $\frac{m - 1}{2}$ 时，互信息量达到最大，AWGN 对应的曲线成为其渐近线。

    这一点也很好解释，因为当 $b$ 如此取值时，输入符号在零点两侧均匀分布，能量最低，故相同
    信噪比下的互信息量最大。同时，当 $M$ 趋向于无穷大时，该信号实际上就是 AWGN，故以其为
    渐近线并不奇怪。

# 参考资料

1. DGrady. [All curves in plot have the same style. Cannot be fixed with Evaluate[]](http://mathematica.stackexchange.com/questions/8637/all-curves-in-plot-have-the-same-style-cannot-be-fixed-with-evaluate) [OL]. Mathematica Stack Exchange, 2012.
2. Wolfram Research. [Wolfram 语言与系统](http://reference.wolfram.com/language/) [OL]. Wolfram Research, 2015.
3. 曹志刚, 钱亚生. 现代通信原理[M]. 清华大学出版社有限公司, 1992.
