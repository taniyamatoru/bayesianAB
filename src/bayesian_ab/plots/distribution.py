import plotly.graph_objects as go


def fig_1d(x, y, title=None) -> go.Figure:
    return go.Figure(
        # Loading the data into the figure
        data=[go.Scatter(x=x, y=y, mode="lines", line=dict(width=2, color="blue"))],
        # Setting the layout of the graph
        layout=go.Layout(
            xaxis=dict(range=[x.min(), x.max()], autorange=False),
            yaxis=dict(range=[y.min(), y.max() * 0.95 if y.max() < 0 else y.max() * 1.05], autorange=False),
            title=title,
        ),
    )


def figs(xs, ys, names=None, title=None) -> go.Figure:
    if names is None:
        names = [None] * len(xs)
    return go.Figure(
        # Loading the data into the figure
        data=[go.Scatter(x=x, y=y, name=name, mode="lines", line=dict(width=2)) for x, y, name in zip(xs, ys, names)],
        # Setting the layout of the graph
        layout=go.Layout(
            xaxis=dict(range=[xs[0].min(), xs[0].max()], autorange=False),
            yaxis=dict(range=[ys[0].min(), ys[0].max() * 1.01], autorange=False),
            title=title,
        ),
    )
