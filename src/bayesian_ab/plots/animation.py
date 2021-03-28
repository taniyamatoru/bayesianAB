from typing import TYPE_CHECKING, Union

import gif
import numpy as np

from .distribution import fig_1d

if TYPE_CHECKING:
    from bayesian_ab.stats import Distribution


def gen_posterior_animation(
    path: str,
    dists: Union[list["Distribution"], dict[int, "Distribution"]],
    x_min: float,
    x_max: float,
    n=1001,
):

    x = np.linspace(x_min, x_max, n)

    @gif.frame
    def plot(i: int, dist: "Distribution"):
        m = round(dist.mean, 2)
        s = round(dist.std, 3)
        t = dist.__class__.__name__
        title = f"{t}[n={i}, mean={m}, std={s}]"
        p = dist.pdf(x)
        return fig_1d(x, p, title)

    if isinstance(dists, list):
        frames = [plot(i, dist) for i, dist in enumerate(dists)]
    else:
        frames = [plot(i, dist) for i, dist in dists.items()]
    gif.save(frames, path, duration=100)
