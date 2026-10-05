# Third-Party Notices

OxygenDynamicsV2 includes or adapts the components below. Retain their copyright
notices, redistribution conditions and disclaimers when redistributing them.
Their terms do not license the remaining project code or determine its owner.
The original Science_2024 code has a preserved
[MIT licence](licenses/Science_2024-MIT.txt). Licensing of new V2 contributions
remains unconfirmed; [the licensing guide](LICENSING.md) explains the scope.
The dependency terms below remain separate from that original code notice.

## Component inventory and evidence

Reconciled on 5 October 2026 against author-maintained GitHub and official
MathWorks File Exchange licence files. The versions below identify the evidence
consulted, **not the exact historical versions of the bundled source**. Full
licence texts follow; [provenance and SHA-256 records](docs/planning/third-party-licence-provenance.json)
identify the local files and downloaded licence bytes.

| Local file | Retained attribution | Identifiable upstream evidence | Terms |
|---|---|---|---|
| `external/abfload.m` | Harald Hentschke; Forrest Collman; local source also credits Ulrich Egert for `pvpmod.m` | [abfload](https://github.com/fcollman/abfload/tree/021c9ffb661978cc4d8a875e64dc3d696ebf40bc), commit `021c9ffb661978cc4d8a875e64dc3d696ebf40bc` | BSD-2-Clause |
| `external/loadtiff.m` | Yoon-Oh Tak / YoonOh Tak; local header copyright 2012 | [Multipage TIFF stack](https://www.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack), distribution 4.5.0; official source header and release licence retained below | BSD-3-Clause-style, GIST non-endorsement clause |
| `external/saveastiff.m` | Adapted in this project from Multipage TIFF stack by Yoon-Oh Tak | Same upstream component; local adaptation attribution retained | Same TIFF terms |
| `helpers/peakfinder.m` | Nathanael C. Yoder; local header copyright 2015 | [peakfinder](https://www.mathworks.com/matlabcentral/fileexchange/25500-peakfinder-x0-sel-thresh-extrema-includeendpoints-interpolate), distribution 2.0.2, licence copyright 2016 | BSD-2-Clause |
| `helpers/plot_areaerrorbar.m` | Victor Martinez-Cagigal in local source; upstream licence spells the holder Víctor Martínez | [Shaded area error bar plot](https://www.mathworks.com/matlabcentral/fileexchange/58262-shaded-area-error-bar-plot), distribution 1.3.1 | BSD-3-Clause, University of Valladolid non-endorsement clause |
| `helpers/hex2rgb.m` | Chad Greene; upstream source identifies Chad A. Greene | [rgb2hex and hex2rgb](https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb), distribution 1.1.1 | BSD-3-Clause, University of Texas at Austin non-endorsement clause |

The exact original revisions and complete modification histories are not recorded
for these bundled files. `abfload.m` differs from the pinned upstream file; TIFF
helpers and `hex2rgb.m` are adapted. The upstream licence pins provide identifiable
licensing evidence, not proof of byte-identical source or exhaustive rights
clearance. No additional permission requirement was identified in these BSD terms
for ordinary redistribution with retained notices. This does not resolve project
ownership or any unidentified third-party material.

TIFF's 2012 source notice and 2019 distribution notice are both observable in
upstream material. They are retained separately, without replacing either date
or inventing a year range. Likewise retain peakfinder's local 2015 attribution,
also displayed in the [official source viewer](https://viewer.mathworks.com/addons/25500/latest/files/peakfinder.m),
alongside the official 2016 distribution notice. Names already credited by the
local source are preserved; no contributor is assigned new copyright ownership.

Local change, 10 September 2026: `abfload.m` uses the first backslash when
extracting an ABF2 protocol path. Using all backslash positions as the start of
a colon expression failed for ordinary nested Windows paths in original BOI
acquisition files. Signal decoding and calibration formulas are unchanged.
This documented historical change is preserved; this notice task changes no code.

The full texts below reproduce the downloaded licence files verbatim inside
text blocks, except the separately identified TIFF source-header transcription.
Original local MATLAB headers and author attributions remain unchanged.

## abfload

Pinned author-maintained licence; copyright 2009 Forrest Collman and 2004 Harald Hentschke.
[Upstream licence file](https://raw.githubusercontent.com/fcollman/abfload/021c9ffb661978cc4d8a875e64dc3d696ebf40bc/license.txt).

```text
Copyright (c) 2009, Forrest Collman
Copyright (c) 2004, Harald Hentschke
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
```

## Multipage TIFF stack — distribution notice

Official 4.5.0 distribution licence; copyright 2019 YoonOh Tak.
[Upstream licence file](https://addons.mathworks.com/downloads/e5/e588e2c9-4a80-11e4-9553-005056977bd0/4.5.0/license.txt).

```text
Copyright (c) 2019, YoonOh Tak
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
* Neither the name of Gwangju Institute of Science and Technology (GIST) nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## Multipage TIFF stack — retained source-header notice

The official [loadtiff source viewer](https://viewer.mathworks.com/addons/35684/latest/files/loadtiff.m)
and [saveastiff source viewer](https://viewer.mathworks.com/addons/35684/latest/files/saveastiff.m)
both display this 2012 notice. Retrieved 5 October 2026 from the `latest` viewer;
this is a transcription with MATLAB comment markers removed, not a downloaded,
revision-pinned source file. Preserve it alongside the 2019 release-file notice.

```text
Copyright (c) 2012, YoonOh Tak
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in
the documentation and/or other materials provided with the distribution
* Neither the name of the Gwangju Institute of Science and Technology (GIST), Republic of Korea nor the names
of its contributors may be used to endorse or promote products derived
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
```

## peakfinder

Official 2.0.2 distribution licence; copyright 2016 Nathanael C. Yoder. Also retain the local source attribution: Copyright Nathanael C. Yoder 2015 (nyoder@gmail.com).
[Upstream licence file](https://addons.mathworks.com/downloads/e5/e569680a-4a80-11e4-9553-005056977bd0/2.0.2/license.txt).

```text
Copyright (c) 2016, Nathanael C. Yoder
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## Shaded area error bar plot

Official 1.3.1 licence; copyright 2018 Víctor Martínez. Local attribution Copyright (c) 2018, Victor Martinez-Cagigal is retained as well; the previous notice used the ASCII name Victor Martinez.
[Upstream licence file](https://addons.mathworks.com/downloads/bb/bb020821-973a-470c-840a-fb66370313e4/1.3.1/license.txt).

```text
Copyright (c) 2018, Víctor Martínez
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
* Neither the name of University of Valladolid nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

## rgb2hex and hex2rgb

Official 1.1.1 licence; copyright 2014 Chad Greene.
[Upstream licence file](https://addons.mathworks.com/downloads/e5/e5a9c7a3-4a80-11e4-9553-005056977bd0/1.1.1/license.txt).

```text
Copyright (c) 2014, Chad Greene
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
* Neither the name of The University of Texas at Austin nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
