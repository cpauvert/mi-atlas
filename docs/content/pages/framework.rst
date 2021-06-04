A framework to describe microbial interactions
##############################################

:save_as: framework.html
:summary: A description of the framework to catalog microbial interactions
:cover: {static}/extra/cover.jpg

.. figure:: {static}/extra/framework-abstract.png
    :alt: A graphical abstract illustrating the encoding process
    :align: center

    From a microbial interaction (left) between two bacteria (green and blue), questions (center) are asked within the framework to help encode the interaction into a set of binary attributes and further stored in the catalog (right).

Microorganisms engage in interactions in all environments. However the specifics of what participants are involved, where exactly it happens, what compounds are involved, how much such niceties cost to each partner are hard to unravel and comprehend. 

Following a long-standing tradition of classification in biology, `Pacheco and Segrè (2019) <https://doi.org/10.1093/femsle/fnz125>`_ innovated by suggesting a framework to systematically partition microbial interactions that goes beyond the outcomes of the participants.

While probably no framework would fit the ever-changing and full of exceptions world of microbes, the framework used here attempt to convert studied microbial interactions into encoded attributes for ease in exploration, comparison and future quantitative analyses.
Encoding a microbial interations between 2 or 3 participants boils down to answering the following **nine questions**.

.. block-success:: Nine questions to encode a microbial interaction

    1. What are the **names** of the microorganisms involved? (usually easy)
    2. What is the **taxonomic resolution** at which the interaction was studied and which **domain of life** are involved?
    3. Is the mechanism of the studied interaction **specific**?
    4. Is there a documented **cost** of engaging in the interaction and does it differ between participants?
    5. What are the ecological **outcomes** for each participant?
    6. Is the interaction documented to **depends** on physical contact, time or space?
    7. What is the **site** of the mechanism of interaction at the cellular level?
    8. What is the **biome** where the interaction takes place?
    9. What type of **compounds** are involved?

.. note-warning::

    Uncertainties or unknown in some of these questions can be encoded with ``NA`` values.

.. note-danger::

    Answers to the questions of the framework are to be supported by peer-reviewed literature. References to relevant articles are then included along the catalog entry.


For more details on the framework definitions, have a look at the `README <https://github.com/cpauvert/mi-atlas/blob/main/README.md#attributes-of-microbial-interactions>`_ on the project repository and the original `article <https://doi.org/10.1093/femsle/fnz125>`_.
