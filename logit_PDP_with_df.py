from matplotlib import pyplot as plt
import numpy as np

def finite_diff(x, y):
    x = np.asarray(x); y = np.asarray(y)
    return np.gradient(y, x)

# 取当前 matplotlib 配色的前两种颜色，保证两条曲线颜色不同
_palette = plt.rcParams['axes.prop_cycle'].by_key()['color']
c_pdp, c_der = _palette[0], _palette[1]

for i, term in enumerate(best_model_inter_weight.terms):
    # 跳过截距与 2D 张量项，只处理一维 s() 项
    if getattr(term, 'isintercept', False):
        continue
    feat = getattr(term, 'feature', None)
    if feat is None:
        continue
    # term.feature 可能是标量或长度为1的序列
    if isinstance(feat, (list, tuple, np.ndarray)):
        if np.size(feat) != 1:
            continue  # te(...) 等 2D 项跳过
        feat_idx = int(np.array(feat).ravel()[0])
    else:
        feat_idx = int(feat)

    # 生成网格（标准化尺度）并取 link 尺度的偏依赖与其 95%CI
    XX = best_model_inter_weight.generate_X_grid(term=i)
    eta, ci = best_model_inter_weight.partial_dependence(term=i, X=XX, width=0.95)

    # 横轴还原到“原始量纲”
    x_std  = XX[:, feat_idx]
    x_orig = x_std * scaler.scale_[feat_idx] + scaler.mean_[feat_idx]

    order   = np.argsort(x_orig)
    x_plot  = x_orig[order]
    eta_plot= eta[order]
    ci_lo   = ci[:, 0][order]
    ci_hi   = ci[:, 1][order]

    # 一阶导数（对 log-odds 关于原始单位的导数）
    d_eta_dx = finite_diff(x_plot, eta_plot)

    # —— 画到同一张图（双 y 轴）——
    fig, ax1 = plt.subplots()
    ax2 = ax1.twinx()

    # 左轴：link 尺度的 PDP + 95%CI
    line1, = ax1.plot(x_plot, eta_plot, lw=2, color=c_pdp, label='logit尺度下的偏函数')
    ax1.fill_between(x_plot, ci_lo, ci_hi, alpha=0.25, color=c_pdp, label='95% CI ')
    ax1.axhline(0, color='gray', lw=0.8, ls='--')
    ax1.set_xlabel(f'{feature_names[feat_idx]} (原始量纲)')
    ax1.set_ylabel('对log-odds的偏效应')

    # 右轴：一阶导数
    line2, = ax2.plot(x_plot, d_eta_dx, lw=2, color=c_der, label='d(log-odds)/dx')
    ax2.set_ylabel('PDP的一阶导数')

    # 合并图例（来自两个坐标轴）
    lines  = [line1, line2]
    labels = [l.get_label() for l in lines]
    ax1.legend(lines, labels, loc='best')

    plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用 SimHei 字体支持中文
    plt.rcParams['axes.unicode_minus'] = False  # 正常显示负号
    plt.title('logit下的PDP & PDP的一阶导数')
    plt.tight_layout()
    plt.show()
