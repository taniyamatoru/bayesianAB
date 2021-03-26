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
