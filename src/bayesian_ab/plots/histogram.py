from typing import Optional

import numpy as np
import plotly.graph_objs as go


def histogram(
    x,
    title: str,
    x_min: Optional[float] = None,
    x_max: Optional[float] = None,
    size: Optional[float] = None,
    probability: bool = False,
) -> go.Figure:
    histnorm = "probability" if probability else None
    ytitle = "probability" if probability else "count"

    x_min = min(x) if x_min is None else x_min
    x_max = max(x) if x_max is None else x_max
    bins = int((np.log2(len(x)) + 1))
    size = (x_max - x_min) / bins if size is None else size

    data = [
        go.Histogram(
            x=x,
            xbins=dict(
                start=x_min,
                end=x_max,
                size=size,
            ),
            histnorm=histnorm,
        )
    ]
    layout = go.Layout(
        title=title,
        xaxis=dict(title="x"),
        yaxis=dict(title=ytitle),
        # bargap=0.1,
    )
    return go.Figure(data=data, layout=layout)


def histogramAB(
    zN: np.ndarray,
    zP: np.ndarray,
    x_min: Optional[float] = None,
    x_max: Optional[float] = None,
    size: Optional[float] = None,
) -> go.Figure:
    length = len(zN) + len(zP)
    xbins = dict(start=x_min, end=x_max, size=size)
    data = [
        go.Histogram(x=zN, xbins=xbins, name="Negative"),
        go.Histogram(x=zP, xbins=xbins, name="Positive"),
    ]

    layout = go.Layout(
        title=f"Bを採用した時Aを上回る可能性: {len(zP)/length*100:.1f}%",
        xaxis=dict(title="Z(B - A)"),
        yaxis=dict(title="count"),
        bargap=0.1,
    )
    return go.Figure(data=data, layout=layout)
